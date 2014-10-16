# encoding: utf-8
require 'spec_helper'

describe MailManager::Bounce do
  context "when checking pop account" do
    it "should not blow up when mail contains a bad extended char" do
      Delayed::Worker.delay_jobs = true
      send_bounce('bad_utf8_chars.eml')
      MailManager::BounceJob.new.perform
      Delayed::Worker.delay_jobs = false
    end
  end
  def send_bounce(filename)
    PostOffice.start_post_office
    mail = Mail.new(File.read(File.join(Rails.root,'spec','support','files',filename)))
    mail.delivery_method :smtp
    mail.delivery_method.settings.merge!(ActionMailer::Base.smtp_settings)
    mail.deliver
  end
end
