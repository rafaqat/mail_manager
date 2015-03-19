Mail Manager
============

The goal of this project will be to create a plugin for use in any site which will provide an interface to manage mailing lists, scheduling of email mailings, subscribe/unsubscribe from lists by contacts, and view reports of bounces and possible track views of emails. Currently, only one list is supported for subscribe/unsubscribe by contact. An interface is available to provide mailable objects from other plugins.

Requirements
------------
* Rails 3.2.x
* Ruby 1.9.3-x
* [Bundler](http://bundler.io)
* [Delayed::Job](https://github.com/collectiveidea/delayed_job/) - (currently the only queue job runnerwe support)

Optional Dependencies
---------------------
* [RVM](http://rvm.io) - How we control our ruby environment(mainly concerns development)

Installation
------------
* using bundler, edit your Gemfile.. add a one of the following lines:

    gem 'mail_manager', '~>3' # this points to the latest rails stable 3.2.x version
     
    gem 'mail_manager', git: 'https://github.com/LoneStarInternet/mail_manager.git', branch: 'rails3.2.x' # for the bleeding edge rails 3.2.x version

* then run bundle install:

    bundle install

* generate and configure the mail manager settings file at config/mail_manager.yml: (replace table prefix with something... or nothing if you don't want to scope it)  

    rake mail_manager:default_app_config[table_prefix]

* generate migrations  

    rake mail_manager:import_migrations

* generate delayed_jobs (this is the only job runner we support right now)  
  
    rails g delayed_job:active_record

* NOTE: you need to create an email account that will receive bounces from your mailings(and allow POP)... configure in the following file:

* add your routes to config/routes.rb (you can say where with at: '/path')

    mount MailManager::Engine, at: '/admin/mail_manager'

Securing your App
-----------------
We implemented [CanCan](https://github.com/CanCanCommunity/cancancan). If you'd like to secure your actions to certain users and don't currently have any authorization in your app, you can follow the following steps if you want an easy config.. or you could make it more finely grained.. currently its all or nothing:

* if you don't have an app/models/ability.rb(i.e. you don't currently use cancan):

    rails g cancan:ability

* next add the mail manager abilities to your file (which should look something like this):

    class Ability
      include CanCan::Ability
    
      def initialize(user)
        eval MailManager.abilities # this is what you ADD
      end
    end

* next decide whether they just need to log in ... or if they should have a role

  * if they need to at least log in, set the following in their config/mail_manager.yml:

    requires_authentication: true

  * if they need a certain role, the following in their config/mail_manager.yml:

    authorized_roles:
      - admin

  * if you're using roles, User must either respond to 'roles' or 'role' or you can configure a custom role method on your model and configure it in mail_manager.yml like so:

    roles_method: my_role_names

Development
-----------
If you wish to contribute, you should follow these instructions to get up and running:

* clone the repository:

    git clone https://github.com/LoneStarInternet/mail_manager.git

* checkout the rails3.2.x branch:

    cd mail_manager
    git checkout rails3.2.x

* set up your database(currently mysql and sqlite are supported); you can get an example db file by copying one of the examples:

    cd spec/test_app
    cp config/database.mysql.yml config/database.yml # for mysql
    cp config/database.sqlite.yml config/database.yml # for sqlite




