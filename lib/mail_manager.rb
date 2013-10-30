require "mail_manager/version"
require "mail_manager/engine"

# Include hook code here
require File.join(File.dirname(__FILE__), 'workers', 'mail_manager', 'bounce_job.rb')