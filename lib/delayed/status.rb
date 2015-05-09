module ::Delayed
  class StatusException < Exception
  end
  class Status
    def self.ok?(overdue=15.minutes)
      failed_count = Delayed::Job.where('failed_at is not null').count
      raise(::Delayed::StatusException, "There are #{failed_count} failed jobs!"
        ) if failed_count > 0
      elapsed_time = (Time.now - status_job.updated_at).to_i
      raise(::Delayed::StatusException, 
        "Rails3 Status job hasn't run for #{elapsed_time} seconds"
      ) if elapsed_time > overdue
      true
    end
    def self.status_job
      status_job = Job.where("handler like '%StatusJob%'").first
      status_job ||= Job.enqueue StatusJob.new(1.minute.from_now)
    end
  end
end
