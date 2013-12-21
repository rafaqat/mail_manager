# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
TestApp::Application.initialize!

ActionMailer::Base.smtp_settings = {  
  :address              => "mail.lvh.me",  
  :port                 => 25000,  
  :domain               => "mail.lvh.me",
  :enable_starttls_auto => false,
  :ssl => false,
  :tls => false  
}  