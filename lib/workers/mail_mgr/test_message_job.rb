=begin rdoc
Author::    Chris Hauboldt (mailto:biz@lnstar.com)
Copyright:: 2009 Lone Star Internet Inc.

Worker used to check for ready Mailings and process/send them.

=end

module MailMgr
  class TestMessageJob < Struct.new(:repeats_every)
    def perform
      TestMessageJob.run
    end
    def self.run
      while(test_message=get_ready) do
        Rails.logger.info "Sending Test Message for '#{test_message.mailing.subject}' to #{test_message.email_address}"
  	    begin
          test_message.deliver
  	      test_message.change_status(:sent)
  	    rescue => e
  	      test_message.result = "Error: #{e.message} - #{e.backtrace.join("\n")}"
  	      test_message.change_status(:failed)
  	    end
        sleep Conf.mail_mgr_sleep_time_between_messages
      end
    end
  
    def self.get_ready
      Lock.with_lock('mail_mgr_test_message_ready') do |lock|
        test_message = TestMessage.ready.first
        return nil if test_message.nil?
        test_message.change_status('processing')
        return test_message
      end
    end
  end
end
