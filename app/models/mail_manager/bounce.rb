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
    set_table_name "#{Conf.mail_manager['table_prefix']}bounces"
    belongs_to :message, :class_name => 'MailManager::Message'
    belongs_to :mailing, :class_name => 'MailManager::Mailing'
    include StatusHistory
    override_statuses(['needs_manual_intervention','unprocessed','dismissed','resolved','invalid'],'unprocessed')
    before_create :set_default_status
    default_scope :order => "#{Conf.mail_manager['table_prefix']}contacts.last_name, #{Conf.mail_manager['table_prefix']}contacts.first_name, #{Conf.mail_manager['table_prefix']}contacts.email_address",
        :joins => 
        "INNER JOIN #{Conf.mail_manager['table_prefix']}messages on #{Conf.mail_manager['table_prefix']}bounces.message_id=#{Conf.mail_manager['table_prefix']}messages.id "+
        " INNER JOIN #{Conf.mail_manager['table_prefix']}contacts on #{Conf.mail_manager['table_prefix']}messages.contact_id=#{Conf.mail_manager['table_prefix']}contacts.id"
#
    scope :by_mailing_id, lambda {|mailing_id| where(:mailing_id => mailing_id)}
    scope :by_status, lambda {|status| where(:status => status.to_s)}

    attr_protected :id
    #Parses email contents for bounce resolution
    def process
      if status.eql?('unprocessed')
        self.message = Message.find_by_guid(bounce_message_guid)
        self.mailing = message.mailing unless message.nil?
        if message.nil?
          change_status(:invalid)
        elsif delivery_error_code =~ /4\.\d\.\d/
          update_attribute(:comments, delivery_error_message)
          change_status(:resolved)
        elsif delivery_error_code =~ /5\.\d\.\d/
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
      contact.full_name
    end

    def contact_email_address
      if contact.blank?
      "Contact Deleted"
      else
      contact.email_address
      end
    end
  
    def delivery_error_code
      delivery_error_part['status'].try(:body) if delivery_error_part
    end

    def delivery_error_message
      return "No Known Error Message" unless delivery_error_part
      error_message = nil
      return error_message if error_message = delivery_error_part['diagnostic-code'].try(:body)
      return error_message if error_message = get_part_with_header('content-type',/^text\/plain/).try(:body)
      return "No Known Error Message" 
    end

    def delivery_error_part
      return @delivery_error_part if @delivery_error_part
      return @delivery_error_part if @delivery_error_part = get_part_with_header('diagnostic-code') 
      @delivery_error_part = get_part_with_header('content-type',/message\/delivery-status/) 
      begin
        @delivery_error_part = TMail::Mail.parse(TMail::Mail.parse(@delivery_error_part.body).body)
      rescue => e
        @delivery_error_part = nil
      end
      return @delivery_error_part
    end

    # Returns message guid 
    def bounce_message_guid
      guid = nil
      return guid if guid = get_header('X-Bounce-GUID')
      return guid if guid = @email['x-bounce-guid']
      return @email.to_s.gsub(/^.*X-Bounce-GUID:\s*([^\s]+).*$/mi,'\1') if @email.to_s.match(/X-Bounce-GUID:\s*([^\s]+)/mi)
      guid
    end

    # Finds the part of the message that contains the given header
    def get_part_with_header(key,value=nil,part=nil)
      return get_part_with_header(key,value,email) if part.nil?
      key = key.downcase
      return part if part.key?(key) and (value.nil? or part[key].to_s =~ value)
      if part.parts.length == 0
        if part.body.length > 0
          begin
            this_part = TMail::Mail.parse(part.body)
            return false unless this_part
            return get_part_with_header(key,value,TMail::Mail.parse(part.body))
          rescue => e
            #this is to catch tmail errors
          end
        end
      else
        part.parts.each do |this_part|
          part = get_part_with_header(key,value,this_part)
          return part if part
        end
      end
      return false
    end

    # Finds the given header's value
    def get_header(key,value=nil,part=nil)
      part = get_part_with_header(key,value,email) if part.nil?
      return nil unless part
      return part[key].body if part.key?(key) and (value.nil? or part[key].to_s =~ value)
      nil
    end

    def email
      return @email if @email
      @email = TMail::Mail.parse(bounce_message)
    end
  end
end
