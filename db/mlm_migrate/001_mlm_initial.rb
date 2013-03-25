class MlmInitial < ActiveRecord::Migration
  def self.up
    create_table :mlm_mailing_lists do |t|
      t.string :name
      t.text :description
      t.string :status
      t.datetime :status_changed_at
      t.timestamps
    end
    create_table :mlm_subscriptions do |t|
      t.integer :mlm_contact_id
      t.integer :mlm_mailing_list_id
      t.string :status
      t.datetime :status_changed_at
      t.integer :updated_by
      t.timestamps
    end
    create_table :mlm_mailings do |t|
      t.string :subject
      t.string :from_email_address
      t.string :mailable
      t.string :status
      t.datetime :status_changed_at
      t.datetime :scheduled_at
      t.boolean :include_images
      t.timestamps
    end
    create_table :mlm_mailing_lists_mlm_mailings, :id => false do |t|
      t.integer :mlm_mailing_id
      t.integer :mlm_mailing_list_id
    end
    create_table :mlm_messages do |t|
      t.integer :mlm_contact_id
      t.integer :mlm_mailing_id
      t.string :guid
      t.string :status
      t.datetime :status_changed_at
      t.text :result
      t.timestamps
    end
    create_table :mlm_bounces do |t|
      t.integer :mlm_message_id
      t.string :status
      t.datetime :status_changed_at
      t.text :bounce_message
      t.text :comments
      t.timestamps
    end
    create_table :mlm_mailables do |t|
      t.string    :name, :null => false
      t.text      :email_html
      t.text      :email_text
      t.boolean   :reusable  
      t.integer   :updated_by
      t.timestamps
    end
  end

  def self.down
    drop_table :mlm_bounces
    drop_table :mlm_messages
    drop_table :mlm_mailing_lists_mlm_mailings
    drop_table :mlm_mailings
    drop_table :mlm_subscriptions
    drop_table :mlm_mailing_lists
  end
end
