require 'rails_helper'

RSpec.describe Delayed::Status do
  before(:each) do 
    Delayed::Worker.delay_jobs = true
  end
  after(:each) do
    Timecop.return
    Delayed::Worker.delay_jobs = false
  end
  it "Creates a status job when invoked and it doesn't yet exist" do
    expect(Delayed::Status.ok?).to be true
    expect(Delayed::Job.count).to eq(1)
    expect(Delayed::Job.first.handler).to match /Delayed::StatusJob/
    Timecop.travel 20.minutes.from_now
    and_it "gripes when the status job is overdue for a run by the specified time" do
      expect{Delayed::Status.ok?(15.minutes)}.to raise_error(
        Delayed::StatusException, /Status job hasn't run for \d+ seconds/
      )
    end
    and_it "gripes when the status job is overdue for a run for 15 minutes" do
      expect{Delayed::Status.ok?}.to raise_error(
        Delayed::StatusException, /Status job hasn't run for \d+ seconds/
      )
    end
    and_it "is OK when the status job is overdue for only 20 minutes and you ask about 25" do
      expect{Delayed::Status.ok?(25.minutes)}.not_to raise_error
    end
  end
  it "gripes when you have failed jobs" do
    Delayed::Status.ok?
    Delayed::Job.first.update_attribute(:failed_at, Time.now.utc)
    expect{Delayed::Status.ok?}.to raise_error(
      Delayed::StatusException, "There are 1 failed jobs!"
    )
  end
end
