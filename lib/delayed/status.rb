module ::Delayed
  class StatusException < Exception
  end
  class Status
    def self.ok?(overdue=15.minutes)
      job = ::Delayed::StatusJob.first || ::Delayed::StatusJob.enqueue(::Delayed::StatusJob.new)
      failed_count = Delayed::Job.where('failed_at is not null').count
      raise(::Delayed::StatusException, "There are #{failed_count} failed jobs!"
        ) if failed_count > 0
      elapsed_time = (Time.now - job.updated_at).to_i
      raise(::Delayed::StatusException, 
        "Rails3 Status job hasn't run for #{elapsed_time} seconds"
      ) if elapsed_time > overdue
      true
    end
  end
end
