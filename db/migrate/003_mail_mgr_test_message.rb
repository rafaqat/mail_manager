class MailMgrTestMessage < ActiveRecord::Migration
  def self.up
    table_prefix = 'mail_mgr_'
    begin
      table_prefix = Conf.mail_mgr_table_prefix
    rescue
    end
    change_table :"#{table_prefix}messages" do |t|
      t.string :type
      t.string :test_email_address
      t.integer :contact_id
    end
  end
  def self.down
    table_prefix = 'mail_mgr_'
    begin
      table_prefix = Conf.mail_mgr_table_prefix
    rescue
    end
    change_table :"#{table_prefix}messages" do |t|
      t.remove :type
      t.remove :test_email_address
      t.remove :contact_id
    end
  end
end