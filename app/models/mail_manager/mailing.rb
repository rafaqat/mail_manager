=begin rdoc
Author::    Chris Hauboldt (mailto:biz@lnstar.com)
Copyright:: 2009 Lone Star Internet Inc.

Mailing is used to send a Mailable object to an MailingList. It is 'ready' to send when its status is 'scheduled' and 'shcheduled_at' is in the past. MailingJob will poll for 'ready' Mailings and send them.

Statuses
pending - initial state - mailing is waiting to be tested and scheduled - will not send
scheduled - mailing will be sent when it is 'ready' (its status is 'scheduled' and 'shcheduled_at' is in the past)
processing - MailingJob is sending the messages for the mailing
completed - Mailing has been sent

=end

module MailManager
  class Mailing < ActiveRecord::Base
    set_table_name "#{Conf.mail_manager_table_prefix}mailings"
    has_many :messages, :class_name => 'MailManager::Message'
    has_many :test_messages, :class_name => 'MailManager::TestMessage'
    has_many :bounces, :class_name => 'MailManager::Bounce'
    has_and_belongs_to_many :mailing_lists, :class_name => 'MailManager::MailingList',
      :join_table => "#{Conf.mail_manager_table_prefix}mailing_lists_#{Conf.mail_manager_table_prefix}mailings"
    #FIXME why does this break?
    belongs_to :mailable, :polymorphic => true

    accepts_nested_attributes_for :mailable


    validates_presence_of :subject
    #validates_presence_of :mailable

    named_scope :ready, lambda {{:conditions => ["(status='scheduled' AND scheduled_at < ?) OR status='resumed'",Time.now.utc]}}
    named_scope :by_statuses, lambda {|*statuses| {:conditions => ["status in (#{statuses.collect{|bindings,status| '?'}.join(",")})",statuses].flatten}}

    include StatusHistory
    before_create :set_default_status

    def send_one_off_message(contact)
      message = Message.new
      message.contact_id = contact.id
      message.mailing_id = self.id
      message.change_status(:ready)
      message.send_later(:deliver)
    end

    def deliver
      Rails.logger.info "Starting to Process Mailing '#{subject}' ID:#{id}"
      Lock.with_lock("mail_manager_mailing_send[#{id}]") do |lock|
        raise "Mailing not scheduled!" unless status.to_s.eql?('scheduled')
        change_status(:processing)
        initialize_messages
        messages.pending.each do |message|
          if reload.status.to_s != 'processing'
            Rails.logger.warn "Mailing #{id} is no longer in processing status it was changed to #{status} while running"
            return false
          end
	        begin
            # use the cached mailing parts, set messages mailing to self
            message.mailing=self
	          message.change_status(:processing)
            message.deliver
	          message.change_status(:sent)
	        rescue => e
	          message.result = "Error: #{e.message} - #{e.backtrace.join("\n")}"
	          message.change_status(:failed)
	        end
          Rails.logger.debug "Sleeping #{Conf.mail_manager_sleep_time_between_messages} before next message"
          sleep Conf.mail_manager_sleep_time_between_messages
        end
        change_status(:completed) if status.to_s.eql?('processing')
      end
    end

    def mailable
      return @mailable if @mailable
      return self unless mailable_type and mailable_id
      @mailable = mailable_type.constantize.find(mailable_id)
    end

    def self.substitute_values(source,substitutions)
      substitutions.each_pair do |substitution,value|
        if value.blank?
          source.gsub!(/##{substitution}#([^#]*)#/,'\1')
        else
          source.gsub!(/##{substitution}#[^#]*#/,value.to_s)
        end
      end
      if defined? MailManager::ContactableRegistry.respond_to?(:valid_contactable_substitutions)
        MailManager::ContactableRegistry.valid_contactable_substitutions.
          reject{|key| substitutions.keys.include?(key)}.each do |substitution|
          source.gsub!(/##{substitution}#([^#]*)#/,'\1')
        end
      end
      source
    end

    def raw_parts
      @raw_parts ||= mailable.mailable_parts
    end

    def parts(substitutions={})
      parts = []
      raw_parts.each do |type,source|
        parts << [type, Mailing.substitute_values(source.dup,substitutions)]
      end
      parts
    end

    def mailable=(value)
      return if value.nil?
      self[:mailable_type] = value.class.name
      self[:mailable_id] = value.id
    end

    def mailable_class_and_id=(value)
      return if value.nil?
      parts = value.split(/_/)
      self[:mailable_id] = parts.pop
      self[:mailable_type] = parts.join('_')
    end

    #def mailable_attributes=(mailable_attributes={})
    #  mailable_attributes.each_pair do |key,value|
    #  end
    #end

    # creates all of the Messages that will be sent for this mailing
    def initialize_messages
      unless messages.length > 0
        Rails.logger.info "Building mailing messages for mailing(#{id})"
        transaction do
          emails_hash = messages.select{|m| m.type.eql?('MailManager::Message')}.inject(Hash.new){|emails_hash,message| emails_hash.merge(Mailing.clean_email_address(message.email_address)=>1)}
          mailing_lists.each do |mailing_list|
            mailing_list.subscriptions.active.each do |subscription|
              contact = subscription.contact
              next if contact.nil? or contact.deleted?
              email_address = Mailing.clean_email_address(contact.email_address)
              if emails_hash.has_key?(email_address)
                Rails.logger.info "Skipping duplicate address: #{email_address}"
              else
                Rails.logger.info "Adding #{email_address} to mailing #{subject}"
                emails_hash[email_address] = 1
                message = Message.new
                message.subscription = subscription
                message.contact = contact
                message.mailing = self
                message.save
              end
            end
          end
        end
        save
      end
    end

    # clean up an email address for sending FIXME - maybe do a bit more
    def self.clean_email_address(email_address)
      email_address.downcase.strip
    end

    # sends a test message for this mailing to the given address
    def send_test_message(test_email_addresses)
      test_email_addresses.split(/,/).each do |test_email_address|
        puts "Creating test message for #{test_email_address}"
        test_message = TestMessage.new(:test_email_address => test_email_address.strip)
        test_message.mailing_id = self.id
        test_message.save
        test_message.send_later(:deliver)
      end
    end

    # used in select helpers to identify this Mailing's Mailable
    def mailable_thing_and_id
      return '' if mailable.nil?
      return "#{mailable.class.name}_#{mailable.id}"
    end

    def mailing_list_ids=(mailing_list_ids)
      mailing_list_ids.delete('')
      self.mailing_lists = mailing_list_ids.collect{|mailing_list_id| MailingList.find_by_id(mailing_list_id)}
    end

    def can_pause?
      ['processing'].include?(status.to_s)
    end

    def can_edit?
      ['pending','scheduled','paused'].include?(status.to_s)
    end

    def can_cancel?
       ['pending','scheduled','processing','paused','resumed'].include?(status.to_s)
    end

    def can_resume?
      ['paused'].include?(status.to_s)
    end

    def can_schedule?
      ['pending'].include?(status.to_s)
    end

    def schedule
      raise "Unable to schedule" unless can_schedule?
      change_status('scheduled')
      send_at(scheduled_at,:deliver)
    end

    def cancel
      raise "Unable to cancel" unless can_cancel?
      change_status('pending')
      Delayed::Job.active.find(:all, :conditions => ["handler like ?","%MailManager::Mailing:#{id}%deliver%"]).each(&:destroy)
    end

    def resume
      raise "Unable to resume" unless can_resume?
      change_status('resumed')
    end

    def pause
      raise "Unable to pause" unless can_pause?
      change_status('paused')
    end

    def save(*args)
      Rails.logger.warn "Saving #{self.inspect}"
      super
    end

    def valid_statuses
      ['pending','scheduled','processing','paused','resumed','cancelled','completed']
    end

    def default_status
      'pending'
    end
  end
end
