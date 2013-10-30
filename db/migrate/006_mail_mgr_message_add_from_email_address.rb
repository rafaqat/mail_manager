class MailManagerMessageAddFromEmailAddress < ActiveRecord::Migration
  def self.up
    table_prefix = 'mail_manager_'
    begin
      table_prefix = Conf.mail_manager_table_prefix
    rescue
    end
    add_column :"#{table_prefix}messages", :from_email_address, :string
  end

  def self.down
    table_prefix = 'mail_manager_'
    begin
      table_prefix = Conf.mail_manager_table_prefix
    rescue
    end
    remove_column :"#{table_prefix}messages", :from_email_address
  end
end
