module Delayed
  class StatusException < Exception
  end
  class Status
    def self.ok?(overdue=15.minutes)
      job = Delayed::StatusJob.first || Delayed::StatusJob.enqueue(::StatusJob.new)
      elapsed_time = (Time.now - job.updated_at).to_i
      raise(::Delayed::StatusException, "Rails3 Status job has failed at #{job.failed_at} with message: #{job.last_error}") if job.failed?
      raise(::Delayed::StatusException, "Rails3 Status job hasn't run for #{elapsed_time} seconds") if elapsed_time > overdue
      true
    end
  end
end
