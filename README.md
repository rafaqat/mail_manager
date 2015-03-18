=General Requirements=
The goal of this project will be to create a plugin for use in any site which will provide an interface to manage mailing lists, scheduling of email mailings, subscribe/unsubscribe from lists by contacts, and view reports of bounces and possible track views of emails. Currently, only one list is supported for subscribe/unsubscribe by contact. An interface is available to provide mailable objects from other plugins.

=Overview=

==Rails 3.2.x Installation==

=== With Bundler ===
* Modify your Gemfile/add the following gem
 gem 'mail_manager', git: 'git@bender.lnstar.com/var/git/mail_manager'

 bundle install # if you're using bundler

* generate a yml configuration file
 

* generate migrations
 rake mail_manager:import_migrations

* generate delayed_jobs (this is the only job runner we support right now)
 rails g delayed_job:active_record

* migrate the database
 rake db:migrate

* add your routes to config/routes.rb (you can say where with at: '/path')
  mount MailManager::Engine, at: '/admin/mail_manager'


