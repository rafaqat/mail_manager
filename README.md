Mail Manager
============

The goal of this project will be to create a plugin for use in any site which will provide an interface to manage mailing lists, scheduling of email mailings, subscribe/unsubscribe from lists by contacts, and view reports of bounces and possible track views of emails. Currently, only one list is supported for subscribe/unsubscribe by contact. An interface is available to provide mailable objects from other plugins.

See the latest docs at the [Wiki](https://github.com/LoneStarInternet/mail_manager/wiki)

Requirements
------------
* Rails 3.2.x (currently tested with rails 3.2.21)
* Ruby 2.1.5 (currently tested with 2.1.5, we have tested against 1.9.3, but ruby devs no longer support it)
* [Bundler](http://bundler.io)
* [Delayed::Job](https://github.com/collectiveidea/delayed_job/) - (currently the only queue job runnerwe support)

Optional Dependencies
---------------------
* [RVM](http://rvm.io) - How we control our ruby environment(mainly concerns development)
* currently we use github/git for our repository

Installation
------------
Using bundler, edit your Gemfile.. add a one of the following lines:
```ruby
    gem 'mail_manager', '~>3' # this points to the latest rails stable 3.2.x version
    # OR
    gem 'mail_manager', git: 'https://github.com/LoneStarInternet/mail_manager.git', branch: 'rails3.2.x' # for the bleeding edge rails 3.2.x version
```
Then run bundle install:
```
    bundle install
```
Generate and configure the mail manager settings file at config/mail_manager.yml: (replace table prefix with something... or nothing if you don't want to scope it)
```
    rake mail_manager:default_app_config[table_prefix]
```
Generate migrations:
```
    rake mail_manager:import_migrations
```
Generate delayed_jobs (this is the only job runner we support right now):
```
    rails g delayed_job:active_record
```

**NOTE:** you need to create an email account that will receive bounces from your mailings(and allow POP)... configure in the following file:

Add your routes to config/routes.rb (you can say where with at: '/path')
```ruby
    mount MailManager::Engine, at: '/admin/mail_manager'
```

config/mail_manager.yml
-----------------------
This is where amost all of your configuration options are for this gem... current generator will add documentation to it (preserving your current settings) .. we'll probably want to upgrade to something like: [AppConfig](https://github.com/Oshuma/app_config) gem


You can generate this file like above(where table_prefix is for prefixing table names):
```
    rake mail_manager:default_app_config[table_prefix]
```
* This generator adds settings documentation to the yml file
* You can override values with a config/mail_manager.local.yml
* For a full description [See the wiki](https://github.com/LoneStarInternet/mail_manager/wiki/config-mail_manager.yml)

Securing your App
-----------------
We implemented [CanCan](https://github.com/CanCanCommunity/cancancan). If you'd like to secure your actions to certain users and don't currently have any authorization in your app, you can follow the following steps if you want an easy config.. or you could make it more finely grained.. currently its all or nothing:
[See the wiki](https://github.com/LoneStarInternet/mail_manager/wiki/Securing-your-app)

Development
-----------
If you wish to contribute, you should follow these instructions to get up and running:
[See the wiki](https://github.com/LoneStarInternet/mail_manager/wiki/Contributing)
