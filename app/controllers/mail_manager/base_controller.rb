require 'dynamic_form'
class MailManager::BaseController < ApplicationController
  layout MailManager.layout
  helper_method :title, :use_show_for_resources?, :site_url
  
  def title(value=nil)
    @title = value if value.present?
    @title
  end

  def use_show_for_resources?
    MailManager.use_show_for_resources
  rescue 
    false
  end

  def site_url
    MailManager.site_url
  rescue
    "#{default_url_options[:protocol]||'http'}://#{default_url_options[:domain]}"
  end
end