module LetsMigrateThis
  module MigrateClassMethods
    def port_to_polymorphic_association
      all.each do |mailing|
        parts = mailing[:mailable].split(/_/)
        mailing[:mailable_id] = parts.pop
        mailing[:mailable_type] = parts.join('_')
        mailing.save
      end
    end
  end
end

MlmMailing.extend(LetsMigrateThis::MigrateClassMethods)

class MailableAsPolymorphic < ActiveRecord::Migration
  def self.up
    add_column :mlm_mailings, :mailable_type, :string
    add_column :mlm_mailings, :mailable_id, :integer
    add_column :mlm_mailings, :mlm_mailable_id, :integer
    MlmMailing.port_to_polymorphic_association
    remove_column :mlm_mailings, :mailable
  end

  def self.down
  end
end
