module Delayed
  class StatusJob < Struct.new(:next_run)
    def perform
      Job.enqueue StatusJob.new, run_at: (next_run || 1.minute.from_now)
    end
  end
end
