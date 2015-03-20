class User < ActiveRecord::Base
  attr_accessible :email, :first_name, :last_name, :phone

  validates :email, uniqueness: true, presence: true

  def roles
    return ['admin'] if last_name.include?('admin')
    []
  end

  include MailManager::ContactableRegistry::Contactable
end

MailManager::ContactableRegistry.register_contactable("User",{
  first_name: :first_name,
  last_name: :last_name,
  email_address: :email,
  phone: :phone
  })
