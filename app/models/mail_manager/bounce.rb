=begin rdoc
Author::    Chris Hauboldt (mailto:biz@lnstar.com)
Copyright:: 2009 Lone Star Internet Inc.

Used to record messages which are returned to the configured account for 'bounce' in the config/config.yml, and pulled by BounceJob. Also responsible for knowing how to process a bounce by pulling diagnostic codes and a message's guid from the bounced email, unsubscribing users when necessary.

Diagnostic Codes:
5xx - will currently unsubscribe a contact
4xx - is ignored, and marked 'resolved' as they are temporary errors

Statuses:
'unprocessed' - initial status before processing
'needs_manual_intervention' - message identified by guid, but message not understood
'resolved' - message has been resolved during processing, and appropriate action taken
'invalid' - message not identified
'dismissed' - bounce has been dismissed by user
=end

module MailManager
  class Bounce < ActiveRecord::Base
    self.table_name =  "#{MailManager.table_prefix}bounces"
    belongs_to :message, :class_name => 'MailManager::Message'
    belongs_to :mailing, :class_name => 'MailManager::Mailing'
    include StatusHistory
    override_statuses(['needs_manual_intervention','unprocessed','dismissed','resolved','invalid'],'unprocessed')
    before_create :set_default_status
    default_scope :order => "#{MailManager.table_prefix}contacts.last_name, #{MailManager.table_prefix}contacts.first_name, #{MailManager.table_prefix}contacts.email_address",
        :joins => 
        "LEFT OUTER JOIN #{MailManager.table_prefix}messages on #{MailManager.table_prefix}bounces.message_id=#{MailManager.table_prefix}messages.id "+
        " LEFT OUTER JOIN #{MailManager.table_prefix}contacts on #{MailManager.table_prefix}messages.contact_id=#{MailManager.table_prefix}contacts.id"
#
    scope :by_mailing_id, lambda {|mailing_id| where(:mailing_id => mailing_id)}
    scope :by_status, lambda {|status| where(:status => status.to_s)}

    attr_protected :id
    #Parses email contents for bounce resolution
    def process(force=false)
      if status.eql?('unprocessed') || force
        self.message = Message.find_by_guid(bounce_message_guid)
        self.mailing = message.mailing unless message.nil?
        if !from_mailer_daemon?
          change_status(:invalid)
        elsif delivery_error_code =~ /4\.\d\.\d/ || delivery_error_message.to_s =~ /quota/i
          update_attribute(:comments, delivery_error_message)
          change_status(:resolved)
        elsif delivery_error_code =~ /5\.\d\.\d/ && delivery_error_message.present?
          transaction do 
            update_attribute(:comments, delivery_error_message)
            change_status(:resolved)
            message.change_status(:failed)
            message.update_attribute(:result,"Failure Message from Bounce: #{delivery_error_message}")
            Subscription.fail_by_email_address(contact_email_address)
          end
        else
          update_attribute(:comments, 'unrecognized diagnostic code')
          change_status(:needs_manual_intervention)
        end
        save
      end
    end

    def reprocess
      process(true)
    end

    def from_mailer_daemon?
      ['postmaster','mailer-daemon'].include?(email.from.first.gsub(/\@.*$/,'').downcase)
    end
  
    def dismiss
      raise "Status cannot be manually changed unless it needs manual intervention!" unless
        status.eql?('needs_manual_intervention')
      change_status(:dismissed)
    end
  
    def fail_address
      raise "Status cannot be manually changed unless it needs manual intervention!"  unless
        status.eql?('needs_manual_intervention')
      transaction do 
        Subscription.fail_by_email_address(contact_email_address)
        message.result = message.result.to_s + "Failed by Administrator: (bounced, not auto resolved) "
        message.change_status(:failed)
        change_status(:resolved)
      end
    end

    def mailing_subject
      message.try(:mailing).try(:subject)
    end
  
    def subscription
      message.try(:subscription)
    end
    
    def contact
      message.try(:contact)
    end
  
    def contact_full_name
      contact.try(:full_name)
    end

    def contact_email_address
      if contact.blank?
        "Contact Deleted"
      else
        contact.email_address
      end
    end
  
    def delivery_error_code
      email.error_status
    rescue
      nil
    end

    def delivery_error_message
      email.diagnostic_code
    rescue
      nil
    end

    # def delivery_error_part
    #   mail.diagnostic_code.split(":").last
    # rescue
    #   nil
    #   # return @delivery_error_part if @delivery_error_part
    #   # return @delivery_error_part if @delivery_error_part = get_part_with_header('diagnostic-code') 
    #   # @delivery_error_part = get_part_with_header('content-type',/message\/delivery-status/) 
    #   # begin
    #   #   @delivery_error_part = Mail.new(Mail.new(@delivery_error_part.body).body)
    #   # rescue => e
    #   #   @delivery_error_part = nil
    #   # end
    #   # return @delivery_error_part
    # end

    # Returns message guid 
    def bounce_message_guid
      email.to_s.gsub(/^.*X-Bounce-GUID:\s*([^\s]+).*$/mi,'\1') if email.to_s.match(/X-Bounce-GUID:\s*([^\s]+)/mi)
    end

    # # Finds the part of the message that contains the given header
    # def get_part_with_header(key,value=nil,part=nil)
    #   return get_part_with_header(key,value,email) if part.nil?
    #   key = key.downcase
    #   return part if part.header[key] and (value.nil? or part.header[key].to_s =~ value)
    #   if part.parts.length == 0
    #     if part.body.length > 0
    #       begin
    #         this_part = Mail.new(part.body)
    #         return false unless this_part
    #         return get_part_with_header(key,value,Mail.new(part.body))
    #       rescue => e
    #         #this is to catch mail errors
    #       end
    #     end
    #   else
    #     part.parts.each do |this_part|
    #       part = get_part_with_header(key,value,this_part)
    #       return part if part
    #     end
    #   end
    #   return false
    # end

    # # Finds the given header's value
    # def get_header(key,value=nil,part=nil)
    #   part = get_part_with_header(key,value,email) if part.nil?
    #   return nil unless part
    #   return part.header[key] if part.header[key].present? and (value.nil? or part.header[key].to_s =~ value)
    #   nil
    # end

    def email
      return @email if @email
      @email = Mail.new(bounce_message)
    end
  end
end
