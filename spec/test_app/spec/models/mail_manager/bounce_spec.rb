# encoding: utf-8
require 'rails_helper'

RSpec.describe MailManager::Bounce do
  context "when checking pop account" do
    it "should not blow up when mail contains a bad extended char" do
      Delayed::Worker.delay_jobs = true
      send_bounce('bad_utf8_chars.eml')
      MailManager::BounceJob.new.perform
      Delayed::Worker.delay_jobs = false
    end
    it "should run every 10 minutes when there is mail on the current run" do
      Delayed::Worker.delay_jobs = true
      send_bounce('bad_utf8_chars.eml')
      MailManager::BounceJob.new.perform
      expect(Delayed::Job.count).to eq(1)
      expect(Delayed::Job.first.run_at.utc.to_i).to be_within(5).of(
        10.minutes.from_now.utc.to_i
      )
      Delayed::Worker.delay_jobs = false
    end
    it "should run every 120 minutes when there is no mail on the current check" do
      Delayed::Worker.delay_jobs = true
      MailManager::BounceJob.new.perform
      expect(Delayed::Job.count).to eq(1)
      expect(Delayed::Job.first.run_at.utc.to_i).to be_within(5).of(
        120.minutes.from_now.utc.to_i
      )
    end
  end
  def send_bounce(filename)
    mail = Mail.new(File.read(File.join(Rails.root,'spec','support','files',filename)))
    mail.delivery_method :smtp
    mail.delivery_method.settings.merge!(ActionMailer::Base.smtp_settings)
    mail.deliver
  end
end
