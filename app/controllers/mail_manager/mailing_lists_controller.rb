module MailManager
  class MailingListsController < BaseController
    before_filter :find_mailing_list, :except => [:new,:create,:index]

    def index
      @mailing_lists = MailingList.active.order("name asc").paginate(:page => params[:page])
    end

    def show
    end

    def new
      @mailing_list = MailingList.new
    end

    def edit
    end

    def create
      @mailing_list = MailingList.new(params[:mailing_list])
      if @mailing_list.save
        flash[:notice] = 'MailingList was successfully created.'
        redirect_to(mail_manager.mailing_lists_path)
      else
        render :action => "new"
      end
    end

    def update
      if @mailing_list.update_attributes(params[:mailing_list])
        flash[:notice] = 'MailingList was successfully updated.'
        redirect_to(mail_manager.mailing_lists_path)
      else
        render :action => "edit"
      end
    end

    def destroy
      @mailing_list.destroy
      redirect_to(mail_manager.mailing_lists_url)
    end
  
    protected 
  
    def find_mailing_list
      @mailing_list = MailingList.find(params[:id])
    end
  end
end