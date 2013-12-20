require "mail_manager/version"
require "mail_manager/engine"
require "deleteable" unless defined?(Deleteable)
# Include hook code here
require File.join(File.dirname(__FILE__), 'workers', 'mail_manager', 'bounce_job.rb')