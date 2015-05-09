require 'delayed_job'
if defined?(Delayed::Job)
  class Delayed::Job
    scope :failed, where("failed_at is not null")
  end
end
