# Sets up the Rails environment for Cucumber
ENV["RAILS_ENV"] ||= "test"
ENV["RAILS_ROOT"] ||= File.dirname(__FILE__) + "/../../spec/test_app"
require File.expand_path(ENV['RAILS_ROOT'] + "/config/environment.rb")
require 'database_cleaner'
require 'cucumber/rails/world'
require 'cucumber/formatter/unicode' # Comment out this line if you don't want Cucumber Unicode support

`rake db:schema:load`

#require "#{MailManager::PLUGIN_ROOT}/spec/factories"
