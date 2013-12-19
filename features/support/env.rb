# Sets up the Rails environment for Cucumber
ENV["Rails.env"] ||= "test"
this_dir =  File.expand_path(File.dirname(__FILE__))
if this_dir.include?('vendor/plugin')
  require File.expand_path(File.dirname(__FILE__) + '/../../../../../config/environment') 
else
  require File.expand_path(File.dirname(__FILE__) + '/../../../config/environment') 
end
require 'cucumber/rails/world'
require 'cucumber/formatter/unicode' # Comment out this line if you don't want Cucumber Unicode support
Cucumber::Rails.use_transactional_fixtures
Cucumber::Rails.bypass_rescue # Comment out this line if you want Rails own error handling 
                              # (e.g. rescue_action_in_public / rescue_responses / rescue_from)

require 'webrat'

Webrat.configure do |config|
  config.mode = :rails
end

require 'cucumber/rails/rspec'
require 'webrat/core/matchers'

`rake db:test:clone_structure`

require "#{MailManager::PLUGIN_ROOT}/spec/factories"
require 'pickle/world'
# Example of configuring pickle:
#
#Pickle.configure do |config|
#  config.adapters = [:factory_girl]
  #config.map 'I', 'myself', 'me', 'my', :to => 'user: "me"'
#end
require 'pickle/path/world'
require 'pickle/email/world'