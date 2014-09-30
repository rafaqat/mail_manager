# encoding: utf-8
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
    self.table_name =  "#{MailManager.table_prefix}mailings"
    has_many :messages, :class_name => 'MailManager::Message'
    has_many :test_messages, :class_name => 'MailManager::TestMessage'
    has_many :bounces, :class_name => 'MailManager::Bounce'
    has_and_belongs_to_many :mailing_lists, :class_name => 'MailManager::MailingList', 
      :join_table => "#{MailManager.table_prefix}mailing_lists_#{MailManager.table_prefix}mailings"
    #FIXME why does this break? 
    belongs_to :mailable, :polymorphic => true
  
    accepts_nested_attributes_for :mailable

    attr_accessor :bounce_count

    validates_presence_of :subject
    #validates_presence_of :mailable
  
    scope :ready, lambda {{:conditions => ["(status='scheduled' AND scheduled_at < ?) OR status='resumed'",Time.now.utc]}}
    scope :by_statuses, lambda {|*statuses| {:conditions => ["status in (#{statuses.collect{|bindings,status| '?'}.join(",")})",statuses].flatten}}
  
    def self.with_bounces(bounce_status=nil)
      bounce_status_condition = bounce_status.present? ? ActiveRecord::Base.send(:sanitize_sql_array,[" WHERE status=?", bounce_status]) : ''
      bounce_query = "SELECT mailing_id, COUNT(id) AS count from #{MailManager.table_prefix}bounces #{bounce_status_condition} group by mailing_id"
      bounce_data = Bounce.connection.execute(bounce_query).inject({}){|hash,(mailing_id,count)| hash.merge(mailing_id => count)}
      mailings = scoped
      mailings = mailings.where("id in (#{bounce_data.keys.select(&:present?).join(',')})") if bounce_data.keys.select(&:present?).present?
      mailings.order("created_at desc").map{|mailing| mailing.bounce_count = bounce_data[mailing.id]; mailing}
    end

    include StatusHistory
    override_statuses(['pending','scheduled','processing','paused','resumed','cancelled','completed'],'pending')
    before_create :set_default_status

    attr_protected :id

    def send_one_off_message(contact)
      message = Message.new
      message.contact_id = contact.id
      message.mailing_id = self.id
      message.change_status(:ready)
      message.delay.deliver
    end
    
    def deliver
      Rails.logger.info "Starting to Process Mailing '#{subject}' ID:#{id}"
      Lock.with_lock("mail_mgr_mailing_send[#{id}]") do |lock|
        unless status.to_s.eql?('scheduled')
          raise Exception.new("Mailing was not scheduled when job tried to run!")
        end
        unless scheduled_at <= Time.now
          Rails.logger.info "Mailing is not scheduled to run until #{scheduled_at} rescheduling job!"
          self.delay(run_at: scheduled_at).deliver
          return true
        end     
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
          Rails.logger.debug "Sleeping #{MailManager.sleep_time_between_messages} before next message"
          sleep MailManager.sleep_time_between_messages
        end
        change_status(:completed) if status.to_s.eql?('processing')
      end
    end
  
    def mailable
      return @mailable if @mailable
      return self unless mailable_type and mailable_id
      @mailable = mailable_type.constantize.find(mailable_id)
    end

    def self.cleanse_source(source)
      require 'iconv' unless String.method_defined?(:encode)
      if String.method_defined?(:encode)
        source.encode!('UTF-16', 'UTF-8', :invalid => :replace, :replace => '')
        source.encode!('UTF-8', 'UTF-16')
      else
        ic = Iconv.new('UTF-8', 'UTF-8//IGNORE')
        source = ic.iconv(source)
      end
    end

    def self.substitute_values(source,substitutions)
      substitutions.each_pair do |substitution,value| 
        if value.blank?
          source.gsub!(/##{substitution}#([^#]*)#/,'\1') rescue source = self.cleanse_source(source).gsub(/##{substitution}#([^#]*)#/,'\1')
        else
          source.gsub!(/##{substitution}#[^#]*#/,value.to_s) rescue source = self.cleanse_source(source).gsub(/##{substitution}#[^#]*#/,value.to_s)
        end
      end
      if defined? MailManager::ContactableRegistry.respond_to?(:valid_contactable_substitutions)
        MailManager::ContactableRegistry.valid_contactable_substitutions.
          reject{|key| substitutions.keys.include?(key)}.each do |substitution|
          source.gsub!(/##{substitution}#([^#]*)#/,'\1') rescue source = self.cleanse_source(source).gsub(/##{substitution}#([^#]*)#/,'\1')
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
        test_message.delay.deliver
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
      delay(run_at: scheduled_at).deliver
    end
  
    def cancel
      raise "Unable to cancel" unless can_cancel?
      change_status('pending')
      # Delayed::Job.active.find(:all, :conditions => ["handler like ?","MailMgr::Mailing"])

      #Changing this to return only the jobs that match the id so I don't have to parse with YAML ... seems logical
      mailing_jobs = Delayed::Job.find(:all, :conditions => ["handler like ?","%MailMgr::Mailing%"] || ["handler like ?", "%id: {job_mailing_id.to_i}\n%"])
      #mailing_jobs = Delayed::Job.active.find(:all, :conditions => ["handler like ?","%MailMgr::Mailing%"])
      mailing_jobs.each do |job|
        #job_mailing_id = YAML::load(job.handler).object.split(':').last
        #logger.debug "Job mailing id: #{job_mailing_id} - This mailing id: #{self.id} - do they match: #{job_mailing_id.to_i == self.id.to_i}"
        job.destroy #if job_mailing_id.to_i == self.id.to_i
      end
    end
  
    def resume
      raise "Unable to resume" unless can_resume?
      change_status('resumed')
    end
  
    def pause
      raise "Unable to pause" unless can_pause?
      change_status('paused')
    end
  end
end
