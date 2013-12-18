require 'dynamic_form'
class MailManager::BaseController < ApplicationController
  layout (Conf.mail_manager['layout'] || 'application') rescue 'application'
  helper_method :title
  def title(value=nil)
    @title = value if value.present?
    @title
  end
end