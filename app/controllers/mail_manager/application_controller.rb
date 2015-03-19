require 'cancan'
require 'dynamic_form'
module MailManager
  class ApplicationController < ::ApplicationController
    layout MailManager.layout
    helper_method :title, :current_user, :use_show_for_resources?, :show_title?
    load_and_authorize_resource


    def title(value=nil)
      if value.nil?
        @page_title
      else
        @page_title = value
        "<h1>#{@page_title}</h1>".html_safe
      end
    end

    def use_show_for_resources?
      ::MailManager.use_show_for_resources
    rescue 
      false
    end

    def show_title?
      return @show_title if defined? @show_title
      true
    end

    def site_url
      ::MailManager.site_url
    rescue
      "#{default_url_options[:protocol]||'http'}://#{default_url_options[:domain]}"
    end
  end
end
