=begin rdoc
Author::    Chris Hauboldt (mailto:biz@lnstar.com)
Copyright:: 2009 Lone Star Internet Inc.

MailingList simply defines the available lists for subscriptions in the system. See Subscription for more information.

=end
module MailManager
  class MailingList < ActiveRecord::Base

    self.table_name =  "#{MailManager.table_prefix}mailing_lists"
    
    # associations get stupid when ActiveRecord is scoped for some horrible reason
    has_many :subscriptions, :class_name => 'MailManager::Subscription'
    has_and_belongs_to_many :mailings, :class_name => 'MailManager::Mailing',
      :join_table => "#{MailManager.table_prefix}mailing_lists_#{MailManager.table_prefix}mailings"
  
    scope :active, {:conditions => {:status => 'active',:deleted_at => nil}}

    validates :name, presence: true
  
    include StatusHistory
    before_create :set_default_status

    attr_protected :id

    def self.active_email_addresses_contact_ids_subscription_ids_for_mailing_list_ids(mailing_list_ids)
      MailManager::MailingList.connection.execute(%Q|select c.email_address as email_address, c.id as contact_id, s.id as subscription_id 
        from #{MailManager.table_prefix}contacts c inner join #{MailManager.table_prefix}subscriptions s on c.id=s.contact_id 
        where s.status in ('active') and mailing_list_id in (#{mailing_list_ids.join(',')})|
      ).inject(Hash.new){|h,r|h.merge!(r[0].to_s.strip.downcase => {contact_id: r[1], subscription_id: r[2]})}
    end

    
    def active?
      deleted_at.nil?
    end
    
    def inactive?
      !active?
    end
  
  end
end
