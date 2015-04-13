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
    previous_method = ActionMailer::Base.delivery_method
    ActionMailer::Base.delivery_method = :test
    Delayed::Job.enqueue BreakMe.new("Funk")
    Delayed::Worker.new(name: 'Bunk').work_off
    Debugging::wait_until_success do
      expect(ActionMailer::Base.deliveries.count).to eq(1)
      expect(ActionMailer::Base.deliveries.first.body).to match /I don't work!Funk/
    end
    Delayed::Worker.delay_jobs = false
    ActionMailer::Base.delivery_method = previous_method
  end
end

