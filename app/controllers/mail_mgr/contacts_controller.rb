module MailMgr
  class ContactsController < ApplicationController
    layout 'admin'

    def subscribe
      if params[:mail_mgr_contact].present? and params[:mail_mgr_contact][:email_address].present?
        @contact = MailMgr::Contact.find_by_email_address(params[:mail_mgr_contact][:email_address])
        @contact = MailMgr::Contact.new if @contact.nil?
        @contact.update_attributes(params[:mail_mgr_contact])
        #check to see what list we subscribed to, if Austin local redirect, if San Antonio, redirect to their thank you page
      end

      if params[:redirect_url].present? #check to see if it came from SA
        redirect_to params[:redirect_url]
      else
        redirect_to mail_mgr_thank_you_path #uncomment after testing...
      end
    end
    
    def send_one_off_message
      @contact = Contact.find(params[:id])
      @mailing = Mailing.find(params[:mailing_id])
      @mailing.send_one_off_message(@contact)
      flash[:info] = "Test message sent to #{@contact.email_address_with_name}"
      redirect_to mail_mgr_contacts_path
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
      @contact = Contact.new(params[:mail_mgr_contact])
      if @contact.save
        flash[:notice] = 'Contact was successfully created.'
        redirect_to(mail_mgr_contacts_path)
      else
        render :action => "new"
      end
    end

    def update
      find_contact
      if @contact.update_attributes(params[:mail_mgr_contact])
        flash[:notice] = 'Contact was successfully updated.'
        redirect_to(mail_mgr_contacts_path)
      else
        render :action => "edit"
      end
    end

    def destroy
      find_contact
      @contact.destroy
      redirect_to(mail_mgr_contacts_url)
    end
  
    protected 
  
    def find_contact
      @contact = Contact.find(params[:id])
    end
  end
end
