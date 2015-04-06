require 'rails_helper'

class BreakMe < Struct.new(:bob)
  def perform
    raise "I don't work!#{bob}"
  end
end

RSpec.describe Delayed::Mailer do
  it "sends an email when a job fails" do
    Delayed::Worker.delay_jobs = true
    Delayed::Worker.max_attempts = 0
    Delayed::Job.delete_all
    ActionMailer::Base.deliveries.clear
    Delayed::Job.enqueue BreakMe.new("Funk")
    Delayed::Worker.new(name: 'Bunk').work_off
    expect(ActionMailer::Base.deliveries.count).to eq(1)
    expect(ActionMailer::Base.deliveries.first.body).to match /I don't work!Funk/
    Delayed::Worker.delay_jobs = false
  end
end

