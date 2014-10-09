require 'delayed_job'
module ::Delayed
  class RepeatingJob < ::Delayed::Job
    def repeats_every
      (@repeats_every ||= payload_object.repeats_every || 1.minutes) rescue 1.minutes
    end

    def repeats_every=(time_span)
      payload_object.repeats_every = time_span if payload_object.respond_to?(:repeats_every)
      @repeats_every = time_span
    end
    
    def total_runs
      begin
        @total_runs ||= payload_object.total_runs || 0
      rescue => e
        @total_runs ||= 0
      end
    end
    
    def total_runs=(value)
      @total_runs = (payload_object.total_runs = value) rescue value 
    end
    
    # I always repeat!
    # Try to run job. Returns true/false (work done/work failed)
    def run(max_run_time=500)
      runtime =  Benchmark.realtime do
        #FIXME: I don't like timeout ... 
        #Timeout.timeout(max_run_time.to_i) { invoke_job }
        invoke_job
      end
      # TODO: warn if runtime > max_run_time ?
      logger.info "* [JOB-#{id}] #{name} completed after %.4f" % runtime
      return repeat
    rescue Exception => e
      begin
        repeat e.message, e.backtrace
      rescue => e2
         logger.warn "Job[#{id}] could not repeat #{e2.message} #{e2.backtrace.join("\n")}"
         self.update_attributes(:failed_at=>Time.now,:last_error => "Could not repeat #{e2.message} #{e2.backtrace.join("\n")}")
      end
      log_exception(e)
      return false  # work failed
    end
  
    # Repeat the job in the future.
    def repeat(message="", backtrace = [])
      unless message.blank?
        self.last_error = %Q|#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}: #{message}\n#{backtrace.join("\n")}
          "\n#{self.last_error}| if message
        self.failed_at = Time.now
        self.attempts += 1
      else 
        self.failed_at = nil
        self.attempts = 0
      end
      while(run_at <= Time.now) do 
        self.run_at += repeats_every
      end
      self.unlock
      self.total_runs += 1
      save!
      reload
      message.blank?
    end
  end
end
