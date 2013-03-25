class AddDeletedAtToMailingLists < ActiveRecord::Migration
  def self.up
    table_prefix = 'mail_mgr_'
    begin
      table_prefix = Conf.mail_mgr_table_prefix
    rescue
    end
    add_column :"#{table_prefix}mailing_lists", :deleted_at, :datetime
  end

  def self.down
    table_prefix = 'mail_mgr_'
    begin
      table_prefix = Conf.mail_mgr_table_prefix
    rescue
    end
    remove_column :"#{table_prefix}mailing_lists", :deleted_at
  end
end
