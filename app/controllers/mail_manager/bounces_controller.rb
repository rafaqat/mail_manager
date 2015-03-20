module MailManager
  class BouncesController < ::MailManager::ApplicationController
    before_filter :find_mailing
  
    def index
      params[:bounce] = Hash.new unless params[:bounce]
      status = params[:bounce][:status] || nil
      @mailings = Mailing.with_bounces(status)
      @bounces = Bounce.scoped
      @bounces = @bounces.by_mailing_id(@mailing.id) if @mailing.present?
      @bounces = @bounces.by_status(status) if status.present?
      @bounces = @bounces.paginate(:page => params[:page])
    end

    def show
    end
  
    protected 
  
    def find_mailing
      return @mailing = Mailing.find_by_id(params[:mailing_id]) if params[:mailing_id]
      return @mailing = @bounce.mailing if @bounce
      nil
    end

  end
end
