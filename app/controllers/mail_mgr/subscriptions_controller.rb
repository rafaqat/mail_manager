module MailMgr
  class SubscriptionsController < ApplicationController
    layout 'admin'
    before_filter :find_subscription, :except => [:new,:create,:index,:unsubscribe,:unsubscribe_by_email_address]
    before_filter :find_mailing_list
    before_filter :find_contact, :except => [:new,:create,:index,:unsubscribe,:unsubscribe_by_email_address]
    skip_before_filter :authorize, :only => [:unsubscribe,:unsubscribe_by_email_address]

    def index
      params[:search] = Hash.new unless params[:search]
      search_params = params[:search].merge(:mailing_list_id => params[:mailing_list_id]) 
      @valid_statuses = Subscription.valid_statuses
      @subscriptions = Subscription.search(search_params).paginate(:all, :page => params[:page])
    end
  
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
      redirect_to mail_mgr_unsubscribe_by_email_address_path
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

    def show
    end

    def new
      @subscription = Subscription.new
      @subscription.mailing_list = @mailing_list
      @contact = @subscription
    end

    def edit
    end

    def create
      @subscription = Subscription.new(params[:mail_mgr_subscription])
      @subscription.mailing_list_id = @mailing_list.id
      if @subscription.save
        flash[:notice] = 'Subscription was successfully created.'
        return redirect_to(mail_mgr_mailing_list_subscriptions_path(@mailing_list))
      else
        @contact = @subscription
        render :action => "new"
      end
    end

    def update
      if @subscription.update_attributes(params[:mail_mgr_subscription])
        @subscription.change_status(params[:mail_mgr_subscription][:status])
        flash[:notice] = 'Subscription was successfully updated.'
        redirect_to(mail_mgr_mailing_list_subscriptions_path(@mailing_list))
      else
        render :action => "edit"
      end
    end

    def destroy
      @subscription.destroy
      redirect_to(mail_mgr_subscriptions_url)
    end
  
    protected 
  
    def find_subscription
      @subscription = Subscription.find(params[:id])
    end

    def find_mailing_list
      return @mailing_list = @subscription.mailing_list if @subscription
      return @mailing_list = MailingList.find_by_id(params[:mailing_list_id]) if params[:mailing_list_id]
      return @mailing_list = MailingList.find_by_id(params[:mail_mgr_subscription][:mailing_list_id]) if
        params[:mail_mgr_subscription]
      nil
    end
  
    def find_contact
      @contact = @subscription.contact
    end
  end
end
