#!/usr/bin/env ruby

# You might want to change this
ENV['RAILS_ENV'] ||= 'production'
require File.dirname(__FILE__) + "/../../config/environment"
require 'workers/mail_manager/mailing_job'
require 'workers/mail_manager/test_message_job'
require 'workers/mail_manager/message_job'
require 'workers/mail_manager/bounce_job'

$running = true
Signal.trap("TERM") do
  $running = false
end

while($running) do
  begin
    MailManager::MailingJob.run
  rescue => e
    Rails.logger.warn " MailManager::MailingJob.run failed.\n#{e.message}\n #{e.backtrace.join("  \n")}"
  end
  begin
    MailManager::MessageJob.run
  rescue => e
    Rails.logger.warn " MailManager::MessageJob.run failed.\n#{e.message}\n #{e.backtrace.join("  \n")}"
  end
  begin
    MailManager::TestMessageJob.run
  rescue => e
    Rails.logger.warn " MailManager::TestMessageJob.run failed.\n#{e.message}\n #{e.backtrace.join("  \n")}"
  end
  begin
    MailManager::BounceJob.run
  rescue => e
    Rails.logger.warn " MailManager::Bounce.run failed.\n#{e.message}\n #{e.backtrace.join("  \n")}"
  end
  sleep 30
end
