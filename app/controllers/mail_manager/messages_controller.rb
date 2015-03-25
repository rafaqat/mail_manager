module MailManager
  class MessagesController < ::MailManager::ApplicationController
    before_filter :find_mailing

    def index
      params[:message] = Hash.new unless params[:message]
      search_params = params[:message].merge(:mailing_id => params[:mailing_id]) 
      @valid_statuses = [['Any Status','']] + Message.valid_statuses.map{|s| [s.capitalize,s]}
      @messages = Message.search(search_params).paginate(:page => params[:page])
    end

    def show
    end
  
    protected
  
    def find_mailing
      return @mailing = Mailing.find_by_id(params[:mailing_id]) if params[:mailing_id]
      return @mailing = @message.message.try(:mailing) if @message
      nil
    end
  end
end
