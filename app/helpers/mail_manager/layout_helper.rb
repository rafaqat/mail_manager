module MailManager
  module LayoutHelper
    def title(value=nil, locals={})
      if value.nil?
        @page_title
      else
        @page_title = translate( value, locals)
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

    def translate(key, options={})
      super(key, options.merge(raise: true))
    rescue I18n::MissingTranslationData
      key
    end
  end
end
