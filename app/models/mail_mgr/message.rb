=begin rdoc
Author::    Chris Hauboldt (mailto:biz@lnstar.com)
Copyright:: 2009 Lone Star Internet Inc.

Message is used in sending a message from an Mailing and keeping state of the message. Generates a "GUID" which is sent in the email and used to identify it in bounces.

Statuses:
pending - MailingJob has created the message but it has not yet been sent
processing - MailingJob is in process of sending the message
sent - MailingJob has successfully sent the message to the Email Server
failed - either the message couldn't be handed to the Email Server or it has been bounced as a permanent failure

=end

module MailMgr
  class Message < ActiveRecord::Base
    set_table_name "#{Conf.mail_mgr_table_prefix}messages"
    belongs_to :mailing, :class_name => 'MailMgr::Mailing'
    belongs_to :subscription, :class_name => 'MailMgr::Subscription'
    has_many :bounces, :class_name => 'MailMgr::Bounce'
    belongs_to :contact, :class_name => 'MailMgr::Contact'
    #FIXME: if we add more types ... change the base message to be MailingMessage or something and don't use
    #me as a message type
    default_scope :conditions => {:type => self.class.name.eql?('Class') ? self.name : self.class.name } 
  
    named_scope :pending, {:conditions => {:status => 'pending'}}
    named_scope :failed, {:conditions => {:status => 'failed'}}
    named_scope :sent, {:conditions => {:status => 'sent'}}
    named_scope :ready, :conditions => ["status=?", 'ready']

    def initialize(*args)
      super
      set_type
    end

    named_scope :search, lambda{|params| 
      conditions = ["1"]
      if params[:mailing_id]
        conditions[0] += " AND #{Conf.mail_mgr_table_prefix}messages.mailing_id=?"
        conditions << params[:mailing_id]
      end
      if params[:status]
        conditions[0] += " AND #{Conf.mail_mgr_table_prefix}messages.status=?"
        conditions << params[:status]
      end
      {
        :conditions => conditions, 
        :order => "#{Conf.mail_mgr_table_prefix}contacts.last_name, #{Conf.mail_mgr_table_prefix}contacts.first_name, #{Conf.mail_mgr_table_prefix}contacts.email_address",
        :joins => " INNER JOIN #{Conf.mail_mgr_table_prefix}contacts on #{Conf.mail_mgr_table_prefix}messages.contact_id=#{Conf.mail_mgr_table_prefix}contacts.id"
      }}
  
    include StatusHistory
    before_create :set_default_status
    after_create :generate_guid

    def email_address_with_name
      return %Q|"#{full_name}" <#{email_address}>|.gsub(/\s+/,' ') unless full_name.eql?('')
      email_address
    end

    # sends the message through Mailer
    def deliver
      MailMgr::Mailer.deliver_message(self)
      change_status(:sent)
    end
  
    def full_name
      contact.full_name
    end

    def email_address
      contact.email_address
    end

    def subject
      mailing.subject
    end

    def from_email_address
      return self[:from_email_address] if self[:from_email_address].present?
      self.update_attribute(:from_email_address,mailing.from_email_address)
      self[:from_email_address]
    end

    # returns the separate mime parts of the message's Mailable
    def parts
      @parts ||= mailing.parts(substitutions)
    end
    
    def contactable
      contact.try(:contactable)
    end

    def substitutions
      substitutions_hash = {}
      MailMgr::ContactableRegistry.registered_methods.each do |method|
        method_key = method.to_s.upcase
        if contact.respond_to?(method)
          substitutions_hash[method_key] = contact.send(method)
        elsif contactable.respond_to?(method)
          substitutions_hash[method_key] = contactable.send(method)
        else
          substitutions_hash[method_key] = ''
        end
      end
      substitutions_hash.merge('UNSUBSCRIBE_URL' => unsubscribe_url)
    end

    def unsubscribe_url
      "#{Conf.site_url}#{Conf.mail_mgr_unsubscribe_path}/#{guid}"
    end
  
    def self.valid_statuses
      ['pending','processing','sent','failed','ready']
    end

    def valid_statuses
      ['pending','processing','sent','failed','ready']
    end
  
    # generated the guid for which the message is identified by in transit
    def generate_guid
      update_attribute(:guid,       
        "#{contact.id}-#{subscription.try(:id)}-#{self.id}-#{Digest::SHA1.hexdigest("#{contact.id}-#{subscription.try(:id)}-#{self.id}-#{Conf.mail_mgr_secret}")}")
    end
  
    def default_status
      'pending'
    end

    protected
    def set_type
      self[:type] = self.class.name
    end
  end
end
