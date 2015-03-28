module MailManager
  class SubscriptionsController < ApplicationController
    skip_before_filter :authorize_resource
    skip_before_filter :load_resource

    def unsubscribe
      raise "Empty id for#{params[:guid]}" if params[:guid].blank?
      if params[:guid] =~ /^test/
        @message = TestMessage.find_by_guid(params[:guid])
        @mailing_lists = ['Test Mailing List'] 
        @contact = Contact.new(:first_name => 'Test', :last_name => 'Guy', 
          :email_address => @message.test_email_address)
      else
        unsubscribed_subscriptions = Subscription.unsubscribe_by_message_guid(params[:guid])
        @mailing_lists = unsubscribed_subscriptions.reject{|subscription|
          subscription.mailing_list.nil?}.collect{|subscription| subscription.mailing_list.name}
        @contact = Message.find_by_guid(params[:guid]).try(:contact)
        raise "Could not find your subscription. Please try unsubscribing with your email address." if @contact.nil?
      end
      render 'unsubscribe', :layout => 'layout'
    rescue => e
      Rails.logger.warn "Error unsubscribing: #{e.message}\n #{e.backtrace.join("\n ")}"
      flash[:error] = e.message
      redirect_to mail_manager.unsubscribe_by_email_address_path
    end
    
    def unsubscribe_by_email_address
      unless params[:email_address].blank?
        unsubscribed_subscriptions = Subscription.unsubscribe_by_email_address(params[:email_address])
        @mailing_lists = unsubscribed_subscriptions.reject{|subscription|
          subscription.mailing_list.nil?}.collect{|subscription| subscription.mailing_list.name}
        @contact = Contact.new(:email_address => params[:email_address])
        return render('unsubscribe', :layout => 'layout')
      end
      render :layout => 'layout'
    end
  end
end
