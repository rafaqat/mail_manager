# require 'rake'
# ENV["RAILS_ENV"] ||= "development"
# require "#{RAILS_ROOT}/config/environment"
# 
# namespace :mail_mgr do 
#   desc "Create mlm LSI Auth Menus"  
#   task :create_auth_menus, :parent_menu do |t,args|
#     Rails.logger.warn "Creating mlm LSI Auth Menus"  
#     parent_menu = args.parent_menu
#      AdminMenu.create_or_find(
#        :description=>'Mailings',
#        :path=>'admin/mail_mgr/mailings',
#        :admin_menu_id=>AdminMenu.find_by_description(parent_menu).id,
#        :menu_order=>15,
#        :is_visible=>1,
#        :auth_all=>1)
#      AdminMenu.create_or_find(
#        :description=>'Mailing Lists',
#        :path=>'admin/mail_mgr/mailing_lists',
#        :admin_menu_id=>AdminMenu.find_by_description(parent_menu).id,
#        :menu_order=>20,
#        :is_visible=>1,
#        :auth_all=>1) 
#      AdminMenu.create_or_find(
#        :description=>'Bounces',
#        :path=>'admin/mail_mgr/bounces',
#        :admin_menu_id=>AdminMenu.find_by_description(parent_menu).id,
#        :menu_order=>30,
#        :is_visible=>1,
#        :auth_all=>1)
#      AdminMenu.create_or_find(
#        :description=>'Contacts',
#        :path=>'admin/mail_mgr/contacts',
#        :admin_menu_id=>AdminMenu.find_by_description('Newsletter').id,
#        :menu_order=>10,
#        :is_visible=>1,
#        :auth_all=>1)
#      AdminMenu.create_or_find(
#        :description=>'MLM General Auth',
#        :path=>'admin/mail_mgr',
#        :admin_menu_id=>nil,
#        :menu_order=>0,
#        :is_visible=>0,
#        :auth_all=>1)
#   end
#   
#   desc "Add mlm defaults to config/config.yml"  
#   task :default_app_config, :table_prefix do |t,args|
#     Rails.logger.warn "Adding defaults to config/config.yml"  
#     begin
#       app_config = YAML.load_file('config/config.yml')
#     rescue => e
#       app_config = Hash.new
#     end
#     File.open('config/config.yml','w') do |file|
#       file.write YAML.dump({
#         'common' => {
#           'mail_mgr_unsubscribe_path' => '/listmgr',
#           'mail_mgr_sleep_time_between_messages' => 0.3,
#           'mail_mgr_path_prefix' => '/admin',
#           'mail_mgr_table_prefix' => args.table_prefix,
#           'mail_mgr_default_from_email_address' => 'eESI <eESINews@eesipeo.com>',
#           'mail_mgr_secret' => ActiveSupport::SecureRandom.hex(15),
#           'mail_mgr_bounce' => {
#               'email_address' => 'test@example.com',
#               'login' => 'test',
#               'password' => 'secret',
#               'pop_server' => 'pop.example.com'
#           }
#         }
#       }.deep_merge(app_config))
#     end
#   end
#   desc "Import  Migrations"
#   task :import_migrations  do 
#     Rails.logger.info "Importing  Migrations"
#     seconds_offset = 1
#     migrations_dir = ::MailMgrPlugin::PLUGIN_ROOT+'/db/migrate'
#     Dir.entries(migrations_dir).
#       select{|filename| filename =~ /^\d+.*rb$/}.sort.each do |filename|
#       migration_name = filename.gsub(/^\d+/,'')
#       if Dir.entries('db/migrate').detect{|file| file =~ /^\d+#{migration_name}$/}
#         puts "Migrations already exist for #{migration_name}"
#       else        
#         Rails.logger.info "Importing  Migration: #{migration_name}"
#         File.open("db/migrate/#{seconds_offset.seconds.from_now.strftime("%Y%m%d%H%M%S")}#{migration_name}",'w') do |file|
#           file.write File.readlines("#{migrations_dir}/#{filename}").join
#         end
#         seconds_offset += 1
#       end
#     end
#   end
#   desc "Create Mailing List" 
#   task :create_mailing_list, :list_name do |t,args|
#     Rails.logger.warn "Creating Mailing List '#{args.list_name}'"
#     MailMgr::MailingList.create(:name => args.list_name)
#   end
#   
#   desc "Create Delayed Jobs for Mail Mgr"
#   task :create_delayed_jobs  do
#     Delayed::RepeatingJob.enqueue(MailMgr::BounceJob.new(15.minutes))
#   end
#   
#   desc "Create Groups and Users"
#   task :import_groups_and_users do
#     groups = ["CORPORATE_GOVERNMENT_GROUP", "CORPORATE_MEDICAL_GROUP", "CORPORATE_BUSINESS_GROUP", "CORPORATE_SCIENCE_AND_TECH_GROUP"]
#      #groups = ["CORPORATE_BUSINESS_GROUP"]
# 
#     groups.each do |group|
#       puts "Processing group #{group}..."
#       mailing_list = MailMgr::MailingList.find(:first, :conditions => ["name=?",group])
#       if mailing_list.nil?
#         mailing_list = MailMgr::MailingList.create(:name => group)
#       end
#       items_read = 0
#       items_added = 0
#       group_file = File.open("#{RAILS_ROOT}/imports/#{group}.csv", "r")
#       #this works with csv file generated on microsoft office for windows
#       group_file.readlines.each do |record|
#           users = record.split(" ")
#           for u in users
#             items_read += 1
#             user = MailMgr::Contact.find(:first, :conditions => ["email_address=?", u])
#             if user.nil?
#               items_added += 1
#               user = MailMgr::Contact.create(:email_address => u)
#             end
#             user.subscribe(mailing_list)
#           end
#   
#       end
#       puts "I read in #{items_read.to_s} items and added #{items_added.to_s} of them."
#     end
#   end
# end
# 
