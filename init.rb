unless defined?(::MailManager::Conf)
  MailManager::Engine.config.to_prepare do
    ApplicationController.helper(MailManager::SubscriptionsHelper)
    if defined?(::Conf)
      ::MailManager::Conf = ::Conf
    else
      require 'mail_manager/config'
      ::MailManager::Conf = ::MailManager::Config.initialize!
    end
  end
end
$stdout.puts "Configured Mail Manager"