=begin rdoc
Author::    Chris Hauboldt (mailto:biz@lnstar.com)
Copyright:: 2009 Lone Star Internet Inc.

Worker used to check for ready Mailings and process/send them.

=end

module MailManager
  class MailingJob < Struct.new(:repeats_every)
    def perform
      MailingJob.run
    end
    def self.run
      while(mailing=get_ready) do
        mailing.deliver
      end
      Rails.logger.info "No ready mailings #{Time.now}"
    end

    def self.get_ready
      Lock.with_lock('mail_manager_mailing_job_ready') do |lock|
        mailing = Mailing.ready.first
        return nil if mailing.nil?
        mailing.change_status('processing')
        return mailing
      end
    end
  end
end