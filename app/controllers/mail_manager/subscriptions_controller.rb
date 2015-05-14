module MailManager
  class SubscriptionsController < ::MailManager::ApplicationController
    skip_authorization_check

    # unsubscribes an email adress by a message's guid(sent in the link)
    def unsubscribe
      raise "Empty id for #{params[:guid]}" if params[:guid].blank?
      if params[:guid] =~ /^test/
        @message = TestMessage.find_by_guid(params[:guid])
        @mailing_lists = ['Test Mailing List'] 
        @email_address = @message.test_email_address
        @contact = Contact.new(:first_name => 'Test', :last_name => 'Guy', 
          :email_address => @message.test_email_address)
      else
        unsubscribed_subscriptions = Subscription.unsubscribe_by_message_guid(params[:guid])
        @mailing_lists = unsubscribed_subscriptions.reject{|subscription|
          subscription.mailing_list.nil?}.collect{|subscription| subscription.mailing_list.name}
        @contact = Message.find_by_guid(params[:guid]).try(:contact)
        raise "Could not find your subscription. Please try unsubscribing with your email address." if @contact.nil?
        @email_address = @contact.email_address
      end
      render 'unsubscribe', :layout => MailManager.public_layout
    rescue => e
      # :nocov: catastrophic failure... shouldn't happen
      Rails.logger.warn "Error unsubscribing: #{e.message}\n #{e.backtrace.join("\n ")}"
      flash[:error] = "We did not recognize that unsubscribe url! Please try unsubscribing with your email address."
      redirect_to main_app.unsubscribe_by_email_address_path
      # :nocov:
    end
    
    # prints/executes form for unsubscribing by email address
    def unsubscribe_by_email_address
      unless params[:email_address].blank?
        unsubscribed_subscriptions = Subscription.unsubscribe_by_email_address(params[:email_address])
        @email_address = params[:email_address]
        @mailing_lists = unsubscribed_subscriptions.reject{|subscription|
          subscription.mailing_list.nil?}.collect{|subscription| subscription.mailing_list.name}
        @contact = Contact.new(:email_address => params[:email_address])
        return render('unsubscribe', :layout => MailManager.public_layout)
      end
      render :layout => MailManager.public_layout
    end
  end
end
