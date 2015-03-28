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

module MailManager
  class Message < ActiveRecord::Base
    self.table_name =  "#{MailManager.table_prefix}messages"
    belongs_to :mailing, :class_name => 'MailManager::Mailing'
    belongs_to :subscription, :class_name => 'MailManager::Subscription'
    has_many :bounces, :class_name => 'MailManager::Bounce'
    belongs_to :contact, :class_name => 'MailManager::Contact'
    #FIXME: if we add more types ... change the base message to be MailingMessage or something and don't use
    #me as a message type
    default_scope :conditions => {:type => "MailManager::#{(self.class.name.eql?('Class') ? self.name : self.class.name).gsub(/^MailManager::/,'')}" } 
  
    scope :pending, {:conditions => {:status => 'pending'}}
    scope :ready, :conditions => ["status=?", 'ready']
    scope :sent, :conditions => ["status=?", 'sent']
    scope :processing, :conditions => ["status=?", 'processing']

    attr_protected :id

    def initialize(*args)
      super
      set_type
    end

    scope :search, lambda{|params| 
      conditions = ["1=1"]
      if params[:mailing_id]
        conditions[0] += " AND #{MailManager.table_prefix}messages.mailing_id=?"
        conditions << params[:mailing_id]
      end
      if params[:status]
        conditions[0] += " AND #{MailManager.table_prefix}messages.status=?"
        conditions << params[:status]
      end
      {
        :conditions => conditions, 
        :order => "#{MailManager.table_prefix}contacts.last_name, #{MailManager.table_prefix}contacts.first_name, #{MailManager.table_prefix}contacts.email_address",
        :joins => " INNER JOIN #{MailManager.table_prefix}contacts on #{MailManager.table_prefix}messages.contact_id=#{MailManager.table_prefix}contacts.id"
      }}
  
    include StatusHistory
    override_statuses(['pending','processing','sent','failed','ready'], 'pending')
    before_create :set_default_status
    after_create :generate_guid

    # returns a string in the form of "contact name" <email@example.com> if 
    # the contact's full name returns anything ... or simply email@example.com if
    # there is no name at all
    def email_address_with_name
      return %Q|"#{full_name}" <#{email_address}>|.gsub(/\s+/,' ') unless full_name.eql?('')
      email_address
    end

    # sends the message through Mailer
    def deliver
      # lock only needed until status is updated
      Lock.with_lock("deliver_message_#{self.id}") do
        reload
        if can_deliver?
          change_status(:processing)
        else
          Rails.logger.warn "Message(#{self.id})'s is no longer suitable to deliver.. staus: #{status}"
        end
      end
      MailManager::Mailer.deliver_message(self)
      change_status(:sent)
    # allow other errors to bubble up
    rescue MailManager::LockException => e
      Rails.logger.warn "Locking error while trying to send MailManager::Message(#{id}) leaving in #{statua} status"
    end

    # whether or not you can deliver a message
    def can_deliver?
      ['ready','pending'].include?(status) 
    end
  
    # returns the contact's full name
    def full_name
      contact.full_name
    end

    # returns the contact's email address
    def email_address
      contact.email_address
    end

    # returns the mailings subject
    def subject
      mailing.subject
    end

    # the "From: " email address for the email
    # lazy sets the from email addres if not present from the mailing 
    def from_email_address
      return self[:from_email_address] if self[:from_email_address].present?
      self.update_attribute(:from_email_address,mailing.from_email_address)
      self[:from_email_address]
    end

    # returns the separate mime parts of the message's Mailable
    def parts
      @parts ||= mailing.parts(substitutions)
    end
    
    # returns the contact's 'contactable' object tied to the contact
    def contactable
      contact.try(:contactable)
    end

    # returns a hash of substitutions to be used to modify the mailable's html/plaing text
    def substitutions
      substitutions_hash = {}
      MailManager::ContactableRegistry.registered_methods.each do |method|
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

    # the full url to unsubscribe based on this message; including site url & guid
    def unsubscribe_url
      "#{MailManager.site_url}#{MailManager.unsubscribe_path}/#{guid}"
    end

    # generated the guid for which the message is identified by in transit
    def generate_guid
      update_attribute(:guid,       
        "#{contact.id}-#{subscription.try(:id)}-#{self.id}-#{Digest::SHA1.hexdigest("#{contact.id}-#{subscription.try(:id)}-#{self.id}-#{MailManager.secret}")}")
    end

    protected
    # nodoc: set the type on create
    def set_type
      self[:type] = self.class.name
    end
  end
end
