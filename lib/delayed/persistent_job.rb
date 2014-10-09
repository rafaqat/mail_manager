module Delayed
  class PersistentJob < Job
    # Try to run job. Returns true/false (work done/work failed)
    @@destroy_failed_jobs = false
    @@destroy_successful_jobs = false
    @@default_max_attempts = 1
  end
end
