require 'delayed_job_active_record'
if defined?(::Delayed::Job)
  require File.join(MailManager::PLUGIN_ROOT,'lib','delayed','status')
  require File.join(MailManager::PLUGIN_ROOT,'lib','delayed','repeating_job')
  require File.join(MailManager::PLUGIN_ROOT,'lib','delayed','status_job')
  require File.join(MailManager::PLUGIN_ROOT,'lib','delayed','persistent_job')
  require File.join(MailManager::PLUGIN_ROOT,'lib','delayed','mailer')
  
  # config/initializers/delayed_job_config.rb
  Delayed::Worker.destroy_failed_jobs = false
  Delayed::Worker.sleep_delay = 60
  Delayed::Worker.max_attempts = 1
  Delayed::Worker.max_run_time = 5.minutes
  Delayed::Worker.read_ahead = 10
  Delayed::Worker.delay_jobs = !Rails.env.test?
  Delayed::Worker.logger = Logger.new(File.join(Rails.root, 'log', 'delayed_job.log'))
end
