#!/usr/bin/env ruby

# You might want to change this
ENV['RAILS_ENV'] ||= 'production'
require File.dirname(__FILE__) + "/../../config/environment"
require 'workers/mail_mgr/mailing_job'
require 'workers/mail_mgr/test_message_job'
require 'workers/mail_mgr/message_job'
require 'workers/mail_mgr/bounce_job'

$running = true
Signal.trap("TERM") do 
  $running = false
end

while($running) do
  begin
    MailMgr::MailingJob.run
  rescue => e
    Rails.logger.warn " MailMgr::MailingJob.run failed.\n#{e.message}\n #{e.backtrace.join("  \n")}"
  end
  begin
    MailMgr::MessageJob.run
  rescue => e
    Rails.logger.warn " MailMgr::MessageJob.run failed.\n#{e.message}\n #{e.backtrace.join("  \n")}"
  end
  begin
    MailMgr::TestMessageJob.run
  rescue => e
    Rails.logger.warn " MailMgr::TestMessageJob.run failed.\n#{e.message}\n #{e.backtrace.join("  \n")}"
  end
  begin
    MailMgr::BounceJob.run
  rescue => e
    Rails.logger.warn " MailMgr::Bounce.run failed.\n#{e.message}\n #{e.backtrace.join("  \n")}"
  end
  sleep 30
end
