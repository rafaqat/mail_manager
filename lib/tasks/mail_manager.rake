require 'rake'
ENV["Rails.env"] ||= "development"
require File.join(Rails.root,'config','environment')
initializer = File.join(MailManager::PLUGIN_ROOT,'config','initializers','delayed_job.rb')
load initializer 

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
      file.write YAML.dump({
        'common' => {
          'site_url' => 'http://example.com',
          'public_layout' => 'layout',
          'site_path' => '/',
          'use_show_for_resources' => false,
          'requires_authentication' => false,
          'authorized_roles' => {
            'to_addresses' => ['bobo@example.com'],
            'from_addresss' => 'admin@example.com'
          },
          'roles_method' => nil,
          'exception_notification' => [],
          'unsubscribe_path' => '/listmgr',
          'dont_include_images_domains' => [
            'yahoo.com', 'google.com', 'hotmail.com', 'aol.com', 'gmail.com',
            'outlook.com'
          ],
          'sleep_time_between_messages' => 0.3,
          'path_prefix' => '/admin',
          'table_prefix' => args.table_prefix,
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

