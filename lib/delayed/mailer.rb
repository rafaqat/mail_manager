class Delayed::Mailer < ActionMailer::Base
  def exception_notification(job,error,emails)
    recipients emails
    from Conf.exception_notification['sender_address'] 
    subject  "* [JOB] #{job.name}(#{job.id}) failed on #{`hostname`} in #{Rails.root}"
    body "* [JOB] #{job.name}(#{job.id}) failed with #{error.class.name}: #{error.message} - #{job.attempts} failed attempts\n  #{error.backtrace.join("\n  ")}"
  end
end
