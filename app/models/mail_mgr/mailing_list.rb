=begin rdoc
Author::    Chris Hauboldt (mailto:biz@lnstar.com)
Copyright:: 2009 Lone Star Internet Inc.

MailingList simply defines the available lists for subscriptions in the system. See Subscription for more information.

=end
module MailMgr
  class MailingList < ActiveRecord::Base
    set_table_name "#{Conf.mail_mgr_table_prefix}mailing_lists"
    
    # associations get stupid when ActiveRecord is scoped for some horrible reason
    has_many :subscriptions, :class_name => 'MailMgr::Subscription'
    has_and_belongs_to_many :mailings, :class_name => 'MailMgr::Mailing',
      :join_table => "#{Conf.mail_mgr_table_prefix}mailing_lists_#{Conf.mail_mgr_table_prefix}mailings"
  
    named_scope :active, {:conditions => {:status => 'active',:deleted_at => nil}}
  
    include StatusHistory
    before_create :set_default_status
    
    def active?
      deleted_at.nil?
    end
    
    def inactive?
      !active?
    end
  
  end
end
