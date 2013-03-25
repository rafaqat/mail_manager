module MailMgr
  class MailingListsController < ApplicationController
    layout 'admin'
    before_filter :find_mailing_list, :except => [:new,:create,:index]

    def index
      @mailing_lists = MailingList.active.find(:all, :order => "name asc").paginate(:page => params[:page])
    end

    def show
    end

    def new
      @mailing_list = MailingList.new
    end

    def edit
    end

    def create
      @mailing_list = MailingList.new(params[:mail_mgr_mailing_list])
      if @mailing_list.save
        flash[:notice] = 'MailingList was successfully created.'
        redirect_to(mail_mgr_mailing_lists_path)
      else
        render :action => "new"
      end
    end

    def update
      if @mailing_list.update_attributes(params[:mail_mgr_mailing_list])
        flash[:notice] = 'MailingList was successfully updated.'
        redirect_to(mail_mgr_mailing_lists_path)
      else
        render :action => "edit"
      end
    end

    def destroy
      @mailing_list.destroy
      redirect_to(mail_mgr_mailing_lists_url)
    end
  
    protected 
  
    def find_mailing_list
      @mailing_list = MailingList.find(params[:id])
    end
  end
end