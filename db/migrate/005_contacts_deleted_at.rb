class ContactsDeletedAt < ActiveRecord::Migration
  def self.up
    table_prefix = 'mail_manager_'
    begin
      table_prefix = Conf.mail_manager_table_prefix
    rescue
    end
    add_column :"#{table_prefix}contacts", :deleted_at, :datetime
  end

  def self.down
    table_prefix = 'mail_manager_'
    begin
      table_prefix = Conf.mail_manager_table_prefix
    rescue
    end
    remove_column :"#{table_prefix}contacts", :deleted_at
  end
end
