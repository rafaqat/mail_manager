module MailMgr
  class ContactableRegistry
    
    @@contactable_things = {}
    def self.register_contactable(classname, methods={})
      @@contactable_things.merge!(classname => methods)
      Rails.logger.warn "Registered Contactable: #{classname}"
      Rails.logger.debug "Current Contactables: #{@@contactable_things.inspect}"
    end
    
    def self.registered_methods(classname=nil)
      return @@contactable_things[classname.to_s].keys unless classname.nil?
      all_methods = {}
      @@contactable_things.values.each do |methods|
        all_methods.merge!(methods)
      end
      all_methods.keys
    end
    
    def self.valid_contactable_substitutions(classname=nil)
      registered_methods(classname).collect{|key| key.to_s.upcase}
    end
  
    def self.contactable_method(classname,method)
      @@contactable_things[classname][method] || method
    end
    
    module Contactable

      #FIXME: this is NOT secure!!!!
      def update_contactable_data
        unless self.is_a?(MailMgr::Contact)
          if self.contact.present?
            self.contact.update_attributes(
              :first_name => contactable_value(:first_name).to_s,
              :last_name => contactable_value(:last_name).to_s,
              :email_address => contactable_value(:email_address).to_s)
          else
            self.contact = Contact.create(
              :contactable => self,
              :first_name => contactable_value(:first_name).to_s,
              :last_name => contactable_value(:last_name).to_s,
              :email_address => contactable_value(:email_address).to_s
            )
          end
        end
        self.contact.present? and self.contact.errors.empty?
      end
      
      def initialize_subscriptions
        if self.contact.nil?
          self.contact = MailMgr::Contact.new(
            :first_name => contactable_value(:first_name).to_s,
            :last_name => contactable_value(:last_name).to_s,
            :email_address => contactable_value(:email_address).to_s)
        end
        self.contact.initialize_subscriptions
      end

      def update_subscription_data
        Rails.logger.debug "Updating Subscriptions: #{@subscriptions_attributes.inspect} - #{subscriptions.inspect}"
        subscriptions.each do |subscription|
          Rails.logger.debug "Updating Subscription attributes for: #{subscription.inspect}"
          unless @subscriptions_attributes.nil?
            subscription_attributes = get_subscription_atttributes_for_subscription(subscription)
            if subscription.new_record? and subscription_attributes[:status] != 'active'
              Rails.logger.debug "Skipping new subscription save, since we're not subscribing"
              subscription.change_status(subscription_attributes[:status],false)
              #mucking with the array messes up the each!
              #subscriptions.delete_if{|my_subscription| my_subscription.mailing_list_id == subscription.mailing_list_id}
            elsif subscription_attributes[:status].present?
              Rails.logger.debug "Changing from #{subscription.status} to #{subscription_attributes[:status]}"
              subscription.change_status(subscription_attributes[:status])
            end
          end
        end
        true
      end
      
      def get_subscription_atttributes_for_subscription(subscription)
        return {} if @subscriptions_attributes.nil?
        subscriptions_attributes.values.detect{|subscription_attributes| 
          subscription_attributes[:mailing_list_id].to_i == subscription.mailing_list_id.to_i} || {}
      end

      def subscribe(mailing_list)
        MailMgr::Subscription.subscribe(self,mailing_list)
      end

      def unsubscribe(mailing_list)
        MailMgr::Subscription.unsubscribe(self,mailing_list)
      end

      def change_subscription_status(mailing_list,status)
        MailMgr::Subscription.change_subscription_status(self,mailing_list,status)
      end

      def contactable_value(method)
        begin
          send(contactable_method(method.to_sym))
        rescue => e
          nil
        end
      end

      def contactable_method(method)
        begin
          MailMgr::ContactableRegistry.contactable_method(self.class,method.to_sym)
        rescue => e
          method
        end
      end
      
      def reload
        @subscriptions = nil
      end
      
      def subscriptions
        return @subscriptions unless @subscriptions.nil?
        @subscriptions = self.initialize_subscriptions
      end
      
      def active_subscriptions
        subscriptions.select{|subscription| subscription.active?}
      end
      
      def save(*args)
        success = true
        if args[0] != false
          begin 
            transaction do 
              success = success && super
              if self.contactable_value(:email_address).present?
                Rails.logger.debug "User save super success? #{success.inspect}"
                success = update_subscription_data && success
                Rails.logger.debug "User save subscription data success? #{success.inspect}"
                success = update_contactable_data unless (!success or self.is_a?(MailMgr::Contact))
                Rails.logger.debug "User save contactable data success? #{success.inspect}"
              end
              raise "Failed to update contactable and/or #{self.class.name} data." unless success
            end
          rescue => e
            Rails.logger.debug "User save failed! #{e.message} #{e.backtrace.join("\n  ")}"
          end
          Rails.logger.debug "User save successful? #{success}"
        else
          success = super
        end
        success
      end

      module Associations
        def self.included(model)
          model.class_eval do
            has_one :contact, :as => :contactable, :class_name => 'MailMgr::Contact'
            #overloading with some extra stuff is better than this
            #has_many :subscriptions, :through => :contact, :class_name => 'MailMgr::Subscription'
          end
        end
      end

      module AttrAccessors
        def self.included(model)
          model.class_eval do
            after_create :save
            attr_accessor :subscriptions_attributes
          end
        end
      end
      
      def self.included(model)
        model.send(:include, Associations)
        model.send(:include, AttrAccessors)
      end
    end
  end
end
