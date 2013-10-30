require 'factory_girl'
require "faker"
module MailManager
Factory.sequence :name do |n|
  "AName#{n}"
end

Factory.define :mailing_list, :class => MailManager::MailingList  do |f|
  Factory.next(:name)
end

Factory.sequence :mailing_list do |n|
  @@mailing_list = nil unless defined? @@mailing_list
  @@mailing_list = @@mailing_list.nil? ? Factory.create(:mailing_list,:name => 'Mailing List') : @@mailing_list
end

Factory.sequence :email do |n|
  "test#{n}@example.com"
end

module LetMeSetMailingListId
  def testable_mailing_list_id=(value)
    self[:mailing_list_id] = value
  end
end
Subscription.send(:include, LetMeSetMailingListId)

Factory.define :subscription,  :class => MailManager::Subscription  do |f|
  f.email_address Factory.next(:email)
  f.testable_mailing_list_id MailingList.find_or_create_by_name("Test Mailing List").id
end

class TestUser < ActiveRecord::Base
  set_table_name "#{Conf.mail_manager_table_prefix}test_users"
  include MailManager::ContactableRegistry::Contactable
end

ActiveRecord::Schema.create_table :"#{Conf.mail_manager_table_prefix}test_users", :force => true do |t|
  t.string :first
  t.string :last
  t.string :email
end

ContactableRegistry.register_contactable(TestUser, {
  :first_name => :first,
  :last_name => :last,
  :email_address => :email
})

Factory.define :test_user,  :class => MailManager::TestUser do |f|
  f.first Factory.next(:name)
  f.last Factory.next(:name)
  f.email Factory.next(:email)
end

Factory.define :test_user_subscription, :parent => :subscription do |f|
  f.contact {|a| a.association(:contact, :email => a.email_address) }
end

require 'mail_manager/mailable_registry'
class TestMailable < ActiveRecord::Base
  set_table_name "#{Conf.mail_manager_table_prefix}test_mailables"
  include MailManager::MailableRegistry::Mailable if defined? MailManager::MailableRegistry.respond_to?(:object_id)
end

ActiveRecord::Schema.create_table :"#{Conf.mail_manager_table_prefix}test_mailables", :force => true do |t|
  t.string :name
  t.string :email_html
  t.string :email_text
end

MailableRegistry.register(TestMailable,{
  :find_mailables => :all,
  :name => :name,
  :parts => {
    'text/html' => :email_html,
    'text/plain' => :email_text
  }
})

Factory.define :test_mailable,  :class => MailManager::TestMailable do |f|
  f.name Factory.next(:name)
  f.email_text {Faker::Lorem.words(20)}
  f.email_html {|a| "<html><body><p>#{a.email_text}</body></html>"}
end

Factory.define :message, :class => MailManager::Message do |f|
  f.association :mailing
  f.association :contact
end

Factory.define :test_message, :class => MailManager::TestMessage do |f|
  f.association :mailing
  f.test_email_address Factory.next(:email)
end

Factory.define :mailing, :class => MailManager::Mailing  do |f|
  f.subject Factory.next(:name)
  f.mailable {Factory.create(:test_mailable)}
end

Factory.define :bounce, :class => MailManager::Bounce do |f|
end
Factory.define :contact, :class => MailManager::Contact do |f|
  f.email_address {Faker::Internet.email}
end
end
