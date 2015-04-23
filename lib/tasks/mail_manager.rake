require 'rake'
ENV["Rails.env"] ||= "development"
require File.join(Rails.root,'config','environment')
initializer = File.join(MailManager::PLUGIN_ROOT,'config','initializers','delayed_job.rb')
load initializer 

def get_config(env,filename='config/mail_manager.yml')
  begin
    app_config = YAML.load_file('config/mail_manager.yml')
  rescue => e
    app_config = Hash.new
  end
end

namespace :mail_manager do
  desc "Add mlm defaults to config/mail_manager.yml"
  task :default_app_config, :table_prefix do |t,args|
    Rails.logger.warn "Adding defaults to config/mail_manager.yml"
    begin
      app_config = YAML.load_file('config/mail_manager.yml')
    rescue => e
      app_config = Hash.new
    end
    File.open('config/mail_manager.yml','w') do |file|
      table_prefix = args.table_prefix || 'mail_manager_'
      file.write <<EOT
# this file is used to configure the mail_manager gem
# it works like an older gem called AppConfig
# all environments start with settings from the 'common' section
# and are overridden by the section that matches the environment's name
# also .. if you create a 'config/mail_manager.local.yml' it will override
# what is in 'config/mail_manager.yml' such that you can keep a  version 
# for local settings and not overwrite one that you include in your source control
# also ... these files allow the use of erb syntax to set variables with ruby thus
# allowing ENV variables and such to be used
# here are the valid settings and what they are for:
# site_url: used in various places to get the url of the site (such as in mailings templates)
# public_layout: layout used for public facing pages like unsubscribing and opt-in pages
# layout: layout used for mail manager administratin pages
# site_path: used in case your rails site is at a sub-path of the site url
# exception_notification: (grouping for who gets notified of exceptions)
#   to_addresses: an array of recipients for exceptions
#   from_address: who the exception appears to be from
# requires_authentication: whether the mail manager app requires login
# authorized_roles: array of role names that can administer the mail manager
# roles_method: the method that your "current_user" object defines its role names(returns a list of strings)
# unsubscribe_path: public url for unsubscribing ... this is a prefix and is followed by a message 'guid', defaults to '/listmgr' and routes as '/listmgr/:guid'
# dont_include_images_domains: a list of domains that won't include images in the email, whether or not the mailing is set to include them
# sleep_time_between_messages: a timeout between messages to slow the output of emails to your email server; you should probably limit with your mail server itself if possible
# path_prefix: a prefix to the mail manager routes(defaults to /admin)
# table_prefix: prefixes all mail manager tables with a string to avoid collisions with your app - should be set BEFORE running migrations
# default_from_email_address: where any public messages from the app default to for the "FROM:" header
# secret: a secret for encrypting tokens and guids
# bounce: (a grouping for 'POP' settings for bounce messages and the RETURN_PATH: header)
#   email_address: the account for POPing bounces and RETURN_PATH
#   login: login for account for POPing
#   password: password for account for POPing
#   pop_server: POP server
#   port: PORT of pop server
#   ssl: true/false whether you want to enable ssl for pop
# subscribe_path: public path for double-opt-in 'subscribe' step which sends the email
# honey_pot_field: used to set a field name which will ignore submissions to the subscribe action if filled
# double_opt_in_path: path to route the double-opt-in confirmation action to
# signup_email_address: email address for the FROM: of a double opt in/subscribe email
#
# The following 2 might be deprecated soon
# show_title: can be used in templates/layouts to see whether you should show a title
# use_show_for_resources: whether to have links to "show" actions - we don't use them really in this app..
# and the 'show' actions aren't really currently supported
#
EOT
      file.write YAML.dump({
        'common' => {
          'site_url' => 'http://example.com',
          'public_layout' => 'layout',
          'site_path' => '/',
          'use_show_for_resources' => false,
          'exception_notification' => {
            'to_addresses' => ['bobo@example.com'],
            'from_address' => 'Mail Manager Exception <admin@example.com>'
          },
          'requires_authentication' => false,
          'roles_method' => nil,
          'authorized_roles' => [],
          'unsubscribe_path' => '/listmgr',
          'subscribe_path' => '/listmgr/subscribe',
          'subscribe_thank_you_path' => '/listmgr/subscribe_thank_you',
          'double_opt_in_path' => '/listmgr/confirm',
          'honey_pot_field' => 'company_name',
          'signup_email_address' => 'Register <signup@example.com>',
          'dont_include_images_domains' => [
            'yahoo.com', 'google.com', 'hotmail.com', 'aol.com', 'gmail.com',
            'outlook.com'
          ],
          'sleep_time_between_messages' => 0.3,
          'path_prefix' => '/admin',
          'table_prefix' => table_prefix,
          'default_from_email_address' => 'Contact <contact@example.com>',
          'secret' => SecureRandom.hex(15).to_s,
          'bounce' => {
              'email_address' => 'bounces@example.com',
              'login' => 'test',
              'password' => 'secret',
              'pop_server' => 'pop.example.com'
          }
        },
        'development' => {
          'site_url' => 'http://example.dev',
          'secret' => SecureRandom.hex(15).to_s
        },
        'test' => {
          'site_url' => 'http://example.lvh.me:4000',
          'secret' => SecureRandom.hex(15).to_s
        }
      }.deep_merge(app_config))
    end
  end
  desc "Import  Migrations"
  task :import_migrations  do
    Rails.logger.info "Importing  Migrations"
    seconds_offset = 1
    migrations_dir = ::MailManager::PLUGIN_ROOT+'/db/migrate'
    FileUtils.mkdir_p('db/migrate') unless File.exists?('db/migrate')
    Dir.entries(migrations_dir).
      select{|filename| filename =~ /^\d+.*rb$/}.sort.each do |filename|
      migration_name = filename.gsub(/^\d+/,'')
      if Dir.entries('db/migrate').detect{|file| file =~ /^\d+#{migration_name}$/}
        puts "Migrations already exist for #{migration_name}"
      else
        Rails.logger.info "Importing  Migration: #{migration_name}"
        File.open("db/migrate/#{seconds_offset.seconds.from_now.strftime("%Y%m%d%H%M%S")}#{migration_name}",'w') do |file|
          file.write File.readlines("#{migrations_dir}/#{filename}").join
        end
        seconds_offset += 1
      end
    end
  end
  desc "Create Mailing List"
  task :create_mailing_list, :list_name do |t,args|
    Rails.logger.warn "Creating Mailing List '#{args.list_name}'"
    MailManager::MailingList.create(:name => args.list_name)
  end

  desc "Create Delayed Jobs for Mail Mgr"
  task :create_delayed_jobs  do
    ::Delayed::RepeatingJob.enqueue(MailManager::BounceJob.new(15.minutes))
  end

  desc "Create Groups and Users"
  task :import_groups_and_users do
    groups = ["CORPORATE_GOVERNMENT_GROUP", "CORPORATE_MEDICAL_GROUP", "CORPORATE_BUSINESS_GROUP", "CORPORATE_SCIENCE_AND_TECH_GROUP"]
     #groups = ["CORPORATE_BUSINESS_GROUP"]

    groups.each do |group|
      puts "Processing group #{group}..."
      mailing_list = MailManager::MailingList.find(:first, :conditions => ["name=?",group])
      if mailing_list.nil?
        mailing_list = MailManager::MailingList.create(:name => group)
      end
      items_read = 0
      items_added = 0
      group_file = File.open("#{RAILS_ROOT}/imports/#{group}.csv", "r")
      #this works with csv file generated on microsoft office for windows
      group_file.readlines.each do |record|
          users = record.split(" ")
          for u in users
            items_read += 1
            user = MailManager::Contact.find(:first, :conditions => ["email_address=?", u])
            if user.nil?
              items_added += 1
              user = MailManager::Contact.create(:email_address => u)
            end
            user.subscribe(mailing_list)
          end

      end
      puts "I read in #{items_read.to_s} items and added #{items_added.to_s} of them."
    end
  end
end

