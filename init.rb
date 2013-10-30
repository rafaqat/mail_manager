unless defined?(MailManager::PLUGIN_ROOT)
  # Include hook code here
  require File.join(File.dirname(__FILE__), 'workers', 'mail_manager', 'bounce_job.rb')

  config.to_prepare do
    ApplicationController.helper(MailManager::SubscriptionsHelper)
    if defined?(::Conf)
      ::MailManager::Conf = ::Conf
    else
      require 'mail_manager/config'
      ::MailManager::Conf = ::MailManager::Config.initialize!
    end
  end
end