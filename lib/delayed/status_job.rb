# module Delayed
#   class StatusJob < RepeatingJob
#     def perform
#       true
#     end

#     def repeats_every
#       1.minutes
#     end

#     # This is a good hook if you need to report job processing errors in additional or different ways
#     def log_exception(error)
#       #don't send mail for this currently.. we'll do something smart laters
#       #Delayed::Mailer.deliver_exception_notification(self,error,notify_email) unless notify_email.blank?
#       logger.error "* [JOB] #{name}(#{id}) failed with #{error.class.name}: #{error.message} - #{attempts} failed attempts"
#     end
#   end
# end
class ::Delayed::StatusJob < Struct.new(:next_run)
  def perform
    ::Delayed::StatusJob.enqueue ::Delayed::StatusJob.new, run_at: (next_run || 1.minute.from_now)
  end
end
