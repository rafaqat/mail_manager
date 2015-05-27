source 'https://rubygems.org'

# Specify your gem's dependencies in mail_manager.gemspec
gem 'dotenv-rails', :require => 'dotenv/rails-now'
gemspec

# jquery-rails is used by the dummy application
gem "devise"
gem "jquery-rails"
gem 'jquery-ui-rails'
gem 'pry-rails'
gem 'spring'
gem 'spring-commands-rspec'
gem 'spring-commands-cucumber'
gem 'thor', '0.19.1'
gem 'delayed_job_active_record'
gem 'sqlite3'
gem 'mysql2'
if ENV['POSTGRES']
  gem 'pg'
end
group :test, :development do
  gem 'foreman'
  gem 'timecop'
  gem 'quiet_assets'
  gem "factory_girl_rails", "~>4.3"
  gem "faker"
  gem 'post_office'
end

#group :test, :development, :post_office do
#  gem 'dotenv'
#  gem 'post_office', "~>0.3"
#end


# Testing Gems
group :test do
  gem 'simplecov', require: false
  gem "rspec-rails", "~>3.2"
  gem "rspec-activemodel-mocks"
  gem 'capybara'
  gem 'poltergeist'
  gem 'database_cleaner'
  gem 'cucumber-rails', require: false
end
