module MailManager
  class ContactsController < ::MailManager::ApplicationController

    include DeleteableActions

    def subscribe
      if params[:contact].present? and params[:contact][:email_address].present?
        @contact = MailManager::Contact.find_by_email_address(params[:contact][:email_address])
        @contact = MailManager::Contact.new if @contact.nil?
        @contact.update_attributes(params[:contact])
        #check to see what list we subscribed to, if Austin local redirect, if San Antonio, redirect to their thank you page
      end

      if params[:redirect_url].present? #check to see if it came from SA
        redirect_to params[:redirect_url]
      else
        redirect_to mail_manager.thank_you_path #uncomment after testing...
      end
    end
    
    def send_one_off_message
      @contact = Contact.find(params[:id])
      @mailing = Mailing.find(params[:mailing_id])
      @mailing.send_one_off_message(@contact)
      flash[:info] = "Test message sent to #{@contact.email_address_with_name}"
      redirect_to mail_manager.contacts_path
    end

    def index
      @mailing_lists = MailingList.order('name').map{|mailing_list| [mailing_list.name,
        mailing_list.id]
      }
      params[:status] ||= 'active'
      @statuses = [["Any", ""], ["Active", "active"], ["Unsubscribed", "unsubscribed"], 
        ["Failed Address", "failed_address"], ["Pending", "pending"]
      ]
      @contacts = Contact.search(params).paginate(:page => params[:page], :per_page => params[:per_page])
    end

    def new
      @contact = Contact.new
    end
    
    def edit
    end
    
    def create
      @contact = Contact.new(params[:contact])
      if @contact.save
        flash[:notice] = 'Contact was successfully created.'
        redirect_to(mail_manager.contacts_path)
      else
        render :action => "new"
      end
    end

    def update
      if @contact.update_attributes(params[:contact])
        flash[:notice] = 'Contact was successfully updated.'
        redirect_to(mail_manager.contacts_path)
      else
        render :action => "edit"
      end
    end

  end
end
