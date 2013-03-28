=begin rdoc
Author::    Chris Hauboldt (mailto:biz@lnstar.com)
Copyright:: 2009 Lone Star Internet Inc.

Worker used to check for ready Messages and process/send them.

=end

module MailManager
  class MessageJob < Struct.new(:repeats_every)
    def perform
      MessageJob.run
    end
    def self.run
      while(message=get_ready) do
        Rails.logger.warn "Sending Message for '#{message.mailing.subject}' to #{message.email_address}"
  	    begin
          message.deliver
  	      message.change_status(:sent)
  	    rescue => e
  	      message.result = "Error: #{e.message} - #{e.backtrace.join("\n")}"
  	      message.change_status(:failed)
  	    end
        sleep Conf.mail_manager_sleep_time_between_messages
      end
    end

    def self.get_ready
      Lock.with_lock('mail_manager_message_ready') do |lock|
        Rails.logger.warn "Finding ready messages"
        message = Message.ready.first
        return nil if message.nil?
        message.change_status('processing')
        return message
      end
    end
  end
end
