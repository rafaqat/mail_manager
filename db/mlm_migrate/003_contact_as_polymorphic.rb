
if defined? User.respond_to?(:object_id)
  module LetsMigrateThisSubscription
    module MigrateClassMethods
      def port_to_polymorphic_association
        all.each do |subscription|
          next if subscription.mlm_mailing_list_id.nil?
          user = User.find_by_id(subscription[:mlm_contact_id])
          next if user.nil?
          if user.respond_to?(:first_name) and user.respond_to?(:last_name)
            subscription.first_name = user.first_name
            subscription.last_name = user.last_name
          elsif user.full_name. =~ /^[^\s]+\s*,/
            name_parts = user.full_name.strip.split(/\s+/)
            subscription.last_name = name_parts.shift.gsub(/,$/,'')
            subscription.first_name = name_parts.join(' ').gsub(/^,/,'')
          else
            name_parts = user.full_name.strip.split(/\s+/)
            subscription.last_name = name_parts.pop
            subscription.first_name = name_parts.join(' ')          
          end
          subscription.email_address = user.email
          subscription[:contactable_id] = subscription[:mlm_contact_id]
          subscription[:contactable_type] = 'User'
          subscription.save
        end
      end
    end
  end
  MlmSubscription.extend(LetsMigrateThisSubscription::MigrateClassMethods)

  module LetsMigrateThisMessage
    module MigrateClassMethods
      def mlm_contact_to_mlm_subscription
        all.each do |message|
          message.mlm_subscription = MlmSubscription.
            find_by_contactable_id_and_contactable_type(message.mlm_contact_id,'User')
          message.save
        end
      end
    end
  end
  MlmMessage.extend(LetsMigrateThisMessage::MigrateClassMethods)
end
MlmMessage.send(:belongs_to, :mlm_subscription)
class ContactAsPolymorphic < ActiveRecord::Migration
  def self.up
    add_column :mlm_subscriptions, :contactable_type, :string
    add_column :mlm_subscriptions, :contactable_id, :integer
    add_column :mlm_subscriptions, :first_name, :string
    add_column :mlm_subscriptions, :last_name, :string
    add_column :mlm_subscriptions, :email_address, :string
    puts "Importing Contact Data into Subscriptions"
    MlmSubscription.port_to_polymorphic_association if defined? User.respond_to?(:object_id)
    remove_column :mlm_subscriptions, :mlm_contact_id
    add_column :mlm_messages, :mlm_subscription_id, :integer
    puts "Updating Messages to connect to subscriptions instead of MlmContacts"
    MlmMessage.mlm_contact_to_mlm_subscription if defined? User.respond_to?(:object_id)
    remove_column :mlm_messages, :mlm_contact_id
  end

  def self.down
  end
end
