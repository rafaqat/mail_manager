require 'digest/md5'
module MailManager
  class ContactsController < ApplicationController
    layout 'admin'

    def subscribe
      if params[:mail_manager_contact].present? and
        params[:mail_manager_contact][:email_address].present? and
        params[:checkomatic].eql?(Digest::MD5.hexdigest(
          params[:mail_manager_contact][:email_address].to_s.strip))
        @contact = MailManager::Contact.find_by_email_address(params[:mail_manager_contact][:email_address])
        @contact = MailManager::Contact.new if @contact.nil?
        @contact.double_opt_in(params[:mail_manager_contact])
        raise @contact.errors.full_messages.join("\n") unless @contact.valid?
        #check to see what list we subscribed to, if Austin local redirect, if San Antonio, redirect to their thank you page
      end
      if request.xhr?
        render :head, :status => '200'
      else
        #if params[:redirect_url].present? #check to see if it came from SA
        #  redirect_to params[:redirect_url]
        #else
        #  redirect_to mail_manager_thank_you_path #uncomment after testing...
        #end
        render :layout => Conf.mail_manager_public_layout
      end
    end

    def thank_you
      render :layout => Conf.mail_manager_public_layout
    end

    def double_opt_in
      @contact = Contact.find_by_token(params[:login_token])
      if @contact.authorized?(params[:login_token])
        @contact.subscriptions.select(&:"pending?").each do |subscription|
          subscription.change_status(:active)
        end
        @mailing_list_names = @contact.subscriptions.select(&:"active?").
          collect(&:mailing_list).collect(&:name)
        @message = "You have successfully subscribed to #{@mailing_list_names.join(',')}!"
      else
        @contact.generate_login_token
        @contact.send_later(:deliver_double_opt_in)
        @message = "Your token has expired! Please check your email for a new one."
      end
      render :layout => Conf.mail_manager_public_layout
    end

    def send_one_off_message
      @contact = Contact.find(params[:id])
      @mailing = Mailing.find(params[:mailing_id])
      @mailing.send_one_off_message(@contact)
      flash[:info] = "Test message sent to #{@contact.email_address_with_name}"
      redirect_to mail_manager_contacts_path
    end

    def index
      @mailings = Mailing.all
      @contacts = Contact.search(params).paginate(:all, :page => params[:page])
    end

    def new
      @contact = Contact.new
    end

    def edit
      find_contact
    end

    def create
      @contact = Contact.new(params[:mail_manager_contact])
      if @contact.save
        flash[:notice] = 'Contact was successfully created.'
        redirect_to(mail_manager_contacts_path)
      else
        render :action => "new"
      end
    end

    def update
      find_contact
      if @contact.update_attributes(params[:mail_manager_contact])
        flash[:notice] = 'Contact was successfully updated.'
        redirect_to(mail_manager_contacts_path)
      else
        render :action => "edit"
      end
    end

    def destroy
      find_contact
      @contact.destroy
      redirect_to(mail_manager_contacts_url)
    end

    protected

    def find_contact
      @contact = Contact.find(params[:id])
    end
  end
end
