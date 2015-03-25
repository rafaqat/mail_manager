require 'rails_helper'

RSpec.describe Delayed::StatusJob do
  it "recreates itself on success" do
    Delayed::Worker.delay_jobs = true
    Delayed::StatusJob.new.perform
    expect(Delayed::Job.count).to eq(1)
    expect(Delayed::Job.first.handler).to match /Delayed::StatusJob/
    expect(Delayed::Job.first.run_at.utc.to_i).to be_within(5).of(
      1.minute.from_now.utc.to_i
    )
  end
end
