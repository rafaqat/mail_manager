module MailManager
  class BouncesController < ApplicationController
    before_filter :find_bounce, :except => [:new, :create, :index]
    before_filter :find_mailing
  
    def index
      params[:bounce] = Hash.new unless params[:bounce]
      @mailings = Mailing.with_bounces(params[:bounce][:status])
      @bounces = []
      @bounces = Bounce.scoped
      @bounces = @bounces.by_mailing_id(@mailing.id) if @mailing.present?
      @bounces = @bounces.by_status(params[:bounce][:status]) if params[:bounce][:status].present?
      @bounces = @bounces.paginate(:page => params[:page])
    end

    def show
    end
  
    protected 
  
    def find_bounce
      @bounce = Bounce.find(params[:id])
    end

    def find_mailing
      return @mailing = Mailing.find_by_id(params[:mailing_id]) if params[:mailing_id]
      return @mailing = @bounce.mailing if @bounce
      nil
    end

  end
end
