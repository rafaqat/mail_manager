=begin rdoc
Author::    Chris Hauboldt (mailto:biz@lnstar.com)
Copyright:: 2009 Lone Star Internet Inc.

Worker used to pop bounces from the bounce email account and create an Bounce to process them.

Configuration:
  config/config.yml in application root

  bounce:
      email_address: bounce@example.com
      login: bounce
      password: secret
      pop_server: pop.example.com

=end
require 'net/pop'
module MailManager
  class BounceJob < Struct.new(:repeats_every)
    def perform
      BounceJob.run
    end
    def self.run
      Lock.with_lock('mail_manager_bounce_job') do
        Rails.logger.info "Bounce Job Connecting to #{MailManager.bounce['pop_server']} with #{MailManager.bounce['login']}:#{MailManager.bounce['password']}"
        Net::POP3.enable_ssl(OpenSSL::SSL::VERIFY_NONE)
        Net::POP3.start(MailManager.bounce['pop_server'],MailManager.bounce['port'],
        	MailManager.bounce['login'], MailManager.bounce['password']) do |pop|

          if pop.mails.empty?
            Rails.logger.info "No mail."
          else
            Rails.logger.info "You have #{pop.mails.length} new bounced messages."
            Rails.logger.info "Downloading..."

            pop.mails.each_with_index do|m,i|
              bounce = Bounce.create({
                :bounce_message => m.pop
              })
              bounce.process
              m.delete
            end
          end
        end
      end
    end
  end
end
