# encoding: utf-8
require 'spec_helper'

describe MailManager::Bounce do
  context "when checking pop account" do
    it "should not blow up when mail contains a bad extended char" do
      send_bounce('bad_utf8_chars.eml')
      MailManager::BounceJob.new.perform
    end
  end
  def send_bounce(filename)
    mail = Mail.new(File.readlines(File.expand_path(File.join(__FILE__,'..','..','..','support','files',filename))).join)
    mail.delivery_method ActionMailer::Base.delivery_method
    mail.delivery_method.settings.merge!(ActionMailer::Base.smtp_settings)
    mail.deliver
  end
end