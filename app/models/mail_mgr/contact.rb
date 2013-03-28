module MailMgr
  class Contact < ActiveRecord::Base
    set_table_name "#{Conf.mail_mgr_table_prefix}contacts"
    has_many :messages, :class_name => 'MailMgr::Message'
    
    belongs_to :contactable, :polymorphic => true
    #not working for some reasom
    #accepts_nested_attributes_for :subscriptions
  
    validates_presence_of :email_address
    #validates_format_of :email_address, :with => Authentication.email_regex, 
    #  :message => Authentication.bad_email_message, :allow_nil => true
    validates_format_of :email_address, :with => /\w{1,}[@][\w\-]{1,}([.]([\w\-]{1,})){1,3}$/, :allow_nil => true

    include MailMgr::ContactableRegistry::Contactable

    named_scope :active, lambda {{:conditions => "#{table_name}.deleted_at IS NULL"}}

    def contact
      self
    end

    named_scope :search, lambda{|params| 
      conditions = ["#{table_name}.deleted_at IS NULL"]
      unless params[:term].blank?
        conditions[0] += " AND (#{params[:term].split(/\s+/).collect{ |term|
          term = "%#{term}%";
          3.times{conditions << term}
          conditions << term if new.respond_to?(:company)
          "(first_name like ? OR last_name like ? OR email_address like ?#{
            " OR company like ?" if new.respond_to?(:company)})"
        }.join(' OR ')})"
      end

      if params[:mailing_list_id]
        conditions[0] += " AND mailing_list_id=?"
        conditions << params[:mailing_list_id]
      end
      unless params[:status].blank?
        conditions[0] += " AND status=?"
        conditions << params[:status]
      end
      { 
        :conditions => conditions, 
        :order =>  'last_name, first_name, email_address'
      }
    }
  
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

    # generated the token for which an opt-in is emailed
    def generate_login_token
      time = Time.now
      token = MailMgr::Contact::inject_contact_id("#{Digest::SHA1.hexdigest(
        "#{self.id}#{Conf.mail_mgr_secret}#{time}")}", self.id)
      self.update_attribute(:login_token, token)
      self.update_attribute(:login_token_created_at, time)
      token
    end

    def double_opt_in_url
      "#{Conf.site_url}#{Conf.mail_mgr_double_opt_in_path}/#{login_token}"
    end

    def double_opt_in(params={})
      previously_active_subscriptions = subscriptions.select(&:"active?")
      self.update_attributes(params)
      make_pending_subscriptions = subscriptions - previously_active_subscriptions
      make_pending_subscriptions.each{|subscription| subscription.change_status(:pending)}
      self.send_later(:deliver_double_opt_in)
    end

    def deliver_double_opt_in
      MailMgr::Mailer.deliver_double_opt_in(self)
    end

    def self.inject_contact_id(token,id)
      token = token.split('')
      id_string = id.to_s.split('')
      new_token = ""
      0.upto(39) do |index|
        new_token << token.pop
        new_token << id_string.shift unless id_string.blank?
      end
      new_token
    end

    def self.extract_contact_id(token)
      token = token.split('')
      id_string = ""
      0.upto(token.length - 41) do |index|
        token.shift
        id_string << token.shift
      end
      id_string.to_i
    end

    def self.find_by_token(token)
      Contact.find_by_id(MailMgr::Contact::extract_contact_id(token))
    end

    def login_token
      self[:login_token] ||= generate_login_token
    end

    def authorized?(token)
      login_token.eql?(token) and login_token_created_at > 7.days.ago
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
      @subscriptions = subscriptions.reject{|subscription| subscription.mailing_list.inactive? or
        subscription.mailing_list.nil?}.sort_by{|subscription|
        subscription.mailing_list.name.downcase}
    end
  end
end
