module MailMgr
  class MessagesController < ApplicationController
    layout 'admin'
    before_filter :find_message, :except => [:new,:create,:index]
    before_filter :find_mailing

    def index
      params[:message] = Hash.new unless params[:message]
      params[:message][:status] = 'failed' if params[:message][:status].nil?
      search_params = params[:message].merge(:mailing_id => params[:mailing_id]) 
      @valid_statuses = Message.valid_statuses
      @messages = Message.search(search_params).paginate(:all, :page => params[:page])
    end

    def show
    end
  
    protected
  
    def find_message
      @message = Message.find(params[:id])
    end

    def find_mailing
      return @mailing = Mailing.find_by_id(params[:mailing_id]) if params[:mailing_id]
      return @mailing = @message.message.try(:mailing) if @message
      nil
    end
  end
end