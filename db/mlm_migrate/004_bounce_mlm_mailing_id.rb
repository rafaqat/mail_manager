module LetsMigrateThisBounce
  module MigrateClassMethods
    def set_mlm_mailing_id
      find(:all, :conditions => ["mlm_message_id is not null"]).each do |bounce|
        unless bounce.mlm_message.nil?
          bounce.mlm_mailing_id = bounce.mlm_message.mlm_mailing.try(:id)
          bounce.save
        end
      end
    end
  end
end
MlmBounce.send(:belongs_to, :mlm_message)
MlmBounce.extend(LetsMigrateThisBounce::MigrateClassMethods)

class BounceMlmMailingId < ActiveRecord::Migration
  def self.up
    add_column :mlm_bounces, :mlm_mailing_id, :integer
    puts "Updating Mlm Mailing Ids"
    MlmBounce.set_mlm_mailing_id
  end

  def self.down
    remove_column :mlm_bounces, :mlm_mailing_id
  end
end
