class MlmToMailManagerScoped < ActiveRecord::Migration

  def self.up
    rename_column :mlm_subscriptions, :mlm_mailing_list_id, :mailing_list_id
    rename_column :mlm_mailing_lists_mlm_mailings, :mlm_mailing_id, :mailing_id
    rename_column :mlm_mailing_lists_mlm_mailings, :mlm_mailing_list_id, :mailing_list_id
    rename_column :mlm_messages, :mlm_mailing_id, :mailing_id
    rename_column :mlm_bounces, :mlm_message_id, :message_id
    remove_column :mlm_mailings, :mlm_mailable_id
    rename_column :mlm_messages, :mlm_subscription_id, :subscription_id
    rename_column :mlm_bounces, :mlm_mailing_id, :mailing_id
    #this is better done with a straight query
    conn = ActiveRecord::Base.connection
    conn.execute("UPDATE `mlm_subscriptions` 
      SET contactable_type='MailManager::Subscription'
      WHERE contactable_type='MlmSubscription'")
  end
  
  def self.down
    rename_column :mlm_subscriptions, :mailing_list_id, :mlm_mailing_list_id
    rename_column :mlm_mailing_lists_mlm_mailings, :mailing_id, :mlm_mailing_id
    rename_column :mlm_mailing_lists_mlm_mailings, :mailing_list_id, :mlm_mailing_list_id
    rename_column :mlm_messages, :mailing_id, :mlm_mailing_id
    rename_column :mlm_bounces, :message_id, :mlm_message_id
    add_column :mlm_mailings, :mlm_mailable_id, :integer
    rename_column :mlm_messages, :subscription_id, :mlm_subscription_id
    rename_column :mlm_bounces, :mailing_id, :mlm_mailing_id
  end
end