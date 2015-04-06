require 'delayed_job'
require 'delayed/worker'
if defined?(Delayed::Worker)
  require File.join(MailManager::PLUGIN_ROOT,'lib','delayed','mailer')
  
  class Delayed::Worker
    def failed(job)
      self.class.lifecycle.run_callbacks(:failure, self, job) do
        begin
          job.hook(:failure) 
        rescue => error
          say "Error when running failure callback: #{error}", 'error'
          say error.backtrace.join("\n"), 'error'
        ensure     
          self.class.destroy_failed_jobs ? job.destroy : job.fail!
          Delayed::Mailer.exception_notification(job).deliver
        end
      end
    end
  end
end
