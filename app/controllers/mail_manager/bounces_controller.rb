module MailManager
  class BouncesController < ApplicationController
    layout 'admin'
    before_filter :find_bounce, :except => [:new, :create, :index]
    before_filter :find_mailing


    def index
      params[:bounce] = Hash.new unless params[:bounce]
      params[:bounce][:status] = 'needs_manual_intervention' unless params[:bounce][:status]
      @mailings = Mailing.by_statuses('processing','paused','resumed','completed','cancelled')
      @mailing = @mailings.first unless @mailing
      @bounces = []
      if params[:bounce][:status].eql?('invalid')
        @bounces = Bounce.by_status('invalid').paginate(:all, :page => params[:page])
      elsif !@mailing.nil?
        @bounces = Bounce.by_mailing_id(@mailing.id).by_status(params[:bounce][:status]).paginate(:all, :page => params[:page])
      end
    end

    def show
    end

    protected

    def find_bounce
      @bounce = Bounce.find(params[:id])
    end

    def find_mailing
      return @mailing = Mailing.find_by_id(params[:mail_manager_mailing_id]) if params[:mail_manager_mailing_id]
      return @mailing = @bounce.mailing if @bounce
      nil
    end

  end
end