module MailManager
  class ContactsController < ::MailManager::ApplicationController

    skip_authorization_check only: [:subscribe,:double_opt_in,:thank_you]

    include DeleteableActions

    def subscribe
      if valid_subscribe_submission?
        @contact = Contact.signup(params[:contact])
        @contact.double_opt_in(params[:mailing_list_ids])
      end

      if params[:redirect_url].present?
        redirect_to params[:redirect_url]
      else
        redirect_to main_app.subscribe_thank_you_path
      end
    end

    def thank_you
      render layout: MailManager.public_layout
    end

    def double_opt_in
      @contact = Contact.find_by_token(params[:login_token])
      if @contact.authorized?(params[:login_token])
        @mailing_list_names = []
        @contact.subscriptions.select(&:"pending?").reject(&:new_record?).each do |subscription|
          subscription.change_status(:active)
          @mailing_list_names << subscription.mailing_list_name
        end
        @message = "You have successfully subscribed to #{@mailing_list_names.join(',')}!"
      else
        @contact.generate_login_token
        @contact.delay.deliver_double_opt_in
        @message = "Your token has expired! Please check your email for a new one."
      end
      render :layout => ::MailManager.public_layout
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

    protected

    def honey_pot_violated?
      params[MailManager.honey_pot_field].present?
    end

    def valid_subscribe_submission? 
      params[:contact].present? && params[:contact][:email_address].present? &&
        !honey_pot_violated?
    end
  end
end
