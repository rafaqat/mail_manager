=begin rdoc
Author::    Chris Hauboldt (mailto:biz@lnstar.com)
Copyright:: 2009 Lone Star Internet Inc.

This class supplies the method for things to be "mailable" from the mailing list manager. Mailable things 
need to be able to be found, have a distinguishable name, have "parts" which contain content for the email and 
register themselves in initialization code. Below is a sample model class and its initialization code.

NOTE!!! you should order the parts in the order you would like them to be placed in the email... the last one seems to be the prefered type of many email clients, although some will have preference settings. In general put the one you want them to see last.



  class Mailable < ActiveRecord::Base
    named_scope :active, :conditions => ['deleted_at is null and published_at<?',Time.now.utc]  
    def name 
      name + created_at
    end 
    def email_html
      "<html><body>Hello World!</body></html>"
    end
    def email_text
      "Hello World!"
    end
  end

  begin
    require 'mailable'
    MailableRegistry.register(MyMailable,{
      :find_mailables => :active,
      :name => :name,
      :parts => [
        ['text/plain' => :email_text],
        ['text/html' => :email_html]
      ]
    })
    Rails.logger.warn "Registered Newsletter Mailable"
  rescue => e
    Rails.logger.warn "Couldn't register Newsletter Mailable #{e.message}"
  end
--
=end

module MailManager
  class MailableRegistry
    attr_reader :mailable_things    

=begin rdoc
    Registers a class as a "mailable" item. 
    Parameters::
      klass => Class constant to be registered
      methods => a hash which maps :find, :name, and mime type to methods; :parts {'mime-type' => :method}
  
    Example Useage:
      you may want to wrap your register in a rescue block if you don't know whether or not the 
      mailing list manager exists in your current project.
    
      begin
        require 'mail_manager/mailable_registry'
        MailableRegistry.register(MyMailable,{
          :find_mailables => :active,
          :name => :name,
          :parts => [
            ['text/plain' => :email_text],
            ['text/html' => :email_html]
          ]
        })
        Rails.logger.debug "Registered Newsletter Mailable"
      rescue => e
        Rails.logger.debug "Couldn't register Newsletter Mailable #{e.message}"
      end
  
=end
    def self.register(klass,methods={})
      Rails.logger.warn "Registered Mailable: #{klass.inspect} - #{methods.inspect}"
      @@mailable_things.merge!({klass => methods})
    end

=begin rdoc
    Finds available mailable items by searching through all registered mailables, calling their finders and sorting by name.
=end
    def self.find
      mailable_items = []
      @@mailable_things.each_pair do |thing,methods|
        Rails.logger.debug "Gathering #{thing} mailables with #{methods[:find_mailables]}"
        mailable_items += thing.constantize.send(methods[:find_mailables])
      end
      mailable_items.sort{|a,b| a.name <=> b.name}
    end  

  
    protected 
    # -- holds registrations of mailables
    @@mailable_things = Hash.new 
  
    def self.mailable_things
      @@mailable_things
    end

    module Mailable
      def mailable_initialize_parts
        @mailable_parts = []
        MailableRegistry.mailable_things[self.class.name][:parts].each{|part,method| 
          @mailable_parts << [part, send(method)]
        }
        @mailable_parts
      end

      def mailable_value(method)
        return send(method) unless MailableRegistry.mailable_things[self.class.name] and
          MailableRegistry.mailable_things[self.class.name][method]
        send(MailableRegistry.mailable_things[self.class.name][method])
      end
    
      def mailable_parts
        return @mailable_parts unless @mailable_parts.nil?
        mailable_initialize_parts
      end

      def self.included(base)
        base.class_eval do
          has_many :mailings, :as => :mailable, :class_name => "MailManager::Mailing"
        end
      end    
    end
  end
end

