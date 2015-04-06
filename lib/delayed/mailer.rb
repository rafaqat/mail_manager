class Delayed::Mailer < ActionMailer::Base
  def exception_notification(job)
    return if MailManager.exception_notification[:to_addresses].blank? || 
     MailManager.exception_notification[:from_address].blank?
    mail(to: MailManager.exception_notification[:to_addresses],
      from: MailManager.exception_notification[:from_address],
      subject: "* [JOB] #{job.name}(#{job.id}) failed on #{`hostname`} in #{Rails.root}",
      body: "* [JOB] #{job.name}(#{job.id}) failed with #{job.last_error} - #{
        job.attempts} failed attempts"
    )
  end
end
