class Ability
  include CanCan::Ability

  def initialize(user)
    eval MailManager.abilities
  end
end
