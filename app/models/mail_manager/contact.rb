module MailManager
  class Contact < ActiveRecord::Base
    self.table_name =  "#{MailManager.table_prefix}contacts"
    has_many :messages, :class_name => 'MailManager::Message'
    
    belongs_to :contactable, :polymorphic => true
    #not working for some reasom
    #accepts_nested_attributes_for :subscriptions
  
    validates_presence_of :email_address
    #validates_format_of :email_address, :with => Authentication.email_regex, 
    #  :message => Authentication.bad_email_message, :allow_nil => true
    validates_format_of :email_address, :with => /\w{1,}[@][\w\-]{1,}([.]([\w\-]{1,})){1,3}$/, :allow_nil => true

    include MailManager::ContactableRegistry::Contactable
    include Deleteable

    attr_protected :id

    def contact
      self
    end
    
    scope :search, lambda{|params| 
      conditions = ["deleted_at IS NULL"]
      joins = {}
      unless params[:term].blank?
        conditions[0] += " AND (#{params[:term].split(/\s+/).collect{ |term|
          term = "%#{term}%";
          3.times{conditions << term}
          "(first_name like ? OR last_name like ? OR email_address like ?)"
        }.join(' OR ')})"
      end

      if params[:mailing_list_id].present? 
        joins = {joins: "INNER JOIN #{MailManager.table_prefix}subscriptions s ON
          s.contact_id=#{MailManager.table_prefix}contacts.id AND s.mailing_list_id=#{params[:mailing_list_id].to_i}"}
      end
      unless params[:status].blank? || params[:mailing_list_id].blank?
        conditions[0] += " AND status=?"
        conditions << params[:status]
      end
      conditions = { 
        :conditions => conditions, 
        :order =>  'last_name, first_name, email_address'
      }
      conditions.merge!(joins) if params[:mailing_list_id].present?
      conditions
    }

    scope :active, lambda {{:conditions => "#{table_name}.deleted_at IS NULL"}}
  
    default_scope :order => 'last_name, first_name, email_address'

    def email_address_with_name
      return %Q|"#{full_name}" <#{email_address}>|.gsub(/\s+/,' ') unless full_name.eql?('')
      email_address
    end

    def full_name
      "#{first_name} #{last_name}".strip
    end

    def deleted?
      !deleted_at.nil?
    end

    def self.signup(params)
      contact = MailManager::Contact.active.find_by_email_address(params['email_address']) 
      contact ||= Contact.new
      Rails.logger.debug "Updating contact(#{contact.new_record? ? "New" : contact.id}) params: #{params.inspect}"
      contact.update_attributes(params)
      contact
    end
        
    def initialize_subscriptions
      @subscriptions = new_record? ? [] : Subscription.find_all_by_contact_id(self.id) 
      MailingList.active.each do |list|
        next if @subscriptions.detect{|subscription| subscription.mailing_list_id.eql?(list.id) }
        Rails.logger.warn "Building Subscription for Mailing List #{list.name}"
        subscription = Subscription.new(:contact => self)
        subscription.mailing_list_id = list.id 
        subscription.change_status((self.new_record? and list.defaults_to_active?) ? :active : :pending,false)
        @subscriptions << subscription
      end
      @subscriptions = subscriptions.reject{|subscription| subscription.mailing_list.try(:inactive?) or
        subscription.mailing_list.nil?}.sort_by{|subscription|
        subscription.mailing_list.name.downcase}
    end
  end
end
