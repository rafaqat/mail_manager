module MailManager
  module LayoutHelper
    def title(value=nil, locals={})
      if value.nil?
        t @page_title, locals
      else
        @page_title = value
        "<h1>#{t @page_title, locals}</h1>".html_safe
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
