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
module MailMgr
  class BounceJob < Struct.new(:repeats_every)
    def perform
      BounceJob.run
    end
    def self.run
      Lock.with_lock('mail_mgr_bounce_job') do |lock|
        Rails.logger.info "Bounce Job Connecting to #{Conf.mail_mgr_bounce['pop_server']} with #{Conf.mail_mgr_bounce['login']}:#{Conf.mail_mgr_bounce['password']}"
        Net::POP3.enable_ssl
        Net::POP3.start(Conf.mail_mgr_bounce['pop_server'],Conf.mail_mgr_bounce['port'],
        	Conf.mail_mgr_bounce['login'], Conf.mail_mgr_bounce['password']) do |pop|

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
