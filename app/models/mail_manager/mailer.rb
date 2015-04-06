=begin rdoc
Author::    Chris Hauboldt (mailto:biz@lnstar.com)
Copyright:: 2009 Lone Star Internet Inc.

This class is responsible for actually sending email messages... its mostly just an ActionMailer, but also has the added functionality to send messages with inline images.

Messages:
unsubscribed - sends an email to notify the user that they have been removed
message - sends and Message 
test_mailing - sends a test message for a mailing
mail - knows how to send any message based on the different "mime" parts its given

=end

require 'open-uri'
require "base64"
begin
  require "mini_magick" 
rescue => e
  # :nocov:
  require 'rmagick' rescue nil
  # :nocov:
end


module MailManager
  class Mailer < ActionMailer::Base
    def unsubscribed(subscriptions,email_address,contact=nil,message=nil)
      @contact = contact
      @email_address = email_address
      @recipients = @email_address
      @from = message.try(:from_email_address) || MailManager.default_from_email_address
      @mailing_lists = subscriptions.reject{|subscription| subscription.mailing_list.nil?}.
        collect{|subscription| subscription.mailing_list.name}
      @subject = "Unsubscribed from #{@mailing_lists.join(',')} at #{MailManager.site_url}"
      Rails.logger.debug "Really Sending Unsubscribed from #{@mailing_lists.first} to #{@email_address}"
      mail(to: @recipients, from: @from, subject: @subject)
    end

    # we do special junk ... so lets make them class methods
    class << self
      def deliver_message(message)
        self.send_mail(message.subject,message.email_address_with_name,message.from_email_address,
          message.parts,message.guid,message.mailing.include_images?)
      end

      def multipart_with_inline_images(subject,to_email_address,from_email_address,the_parts,message_id=nil,include_images=true)
        text_source = the_parts.first[1];nil
        original_html_source = the_parts.last[1];nil
        mail = Mail.new do
          to            to_email_address
          from          from_email_address
          subject       subject
          part :content_type => "multipart/alternative", :content_disposition => "inline" do |main|
            main.part :content_type => "text/plain", :body => text_source
            if include_images
              main.part :content_type => "multipart/related" do |related|
                (html_source,images) = MailManager::Mailer::inline_html_with_images(original_html_source)
                images.each_with_index do |image,index|
                  related.attachments.inline[image[:filename]] = {
                    :content_id => image[:cid],
                    :content => image[:content]
                  }
                  html_source.gsub!(image[:cid],related.attachments[index].cid)
                end
                related.part :content_type => "text/html; charset=UTF-8", :body => html_source
              end
            else
              main.part :content_type => "text/html; charset=UTF-8", :body => original_html_source
            end
          end
        end
        mail
      end

      def multipart_alternative_without_images(subject,to_email_address,from_email_address,the_parts,message_id=nil,include_images=true)
        text_source = the_parts.first[1];nil
        original_html_source = the_parts.last[1];nil
        mail = Mail.new do
          to            to_email_address
          from          from_email_address
          subject       subject

          text_part do
            body text_source
          end

          html_part do
            content_type 'text/html; charset=UTF-8'
            body original_html_source
          end
        end
        mail
      end
    
      def send_mail(subject,to_email_address,from_email_address,the_parts,message_id=nil,include_images=true)
        include_images = (include_images and !MailManager.dont_include_images_domains.detect{|domain| 
          to_email_address.strip =~ /#{domain}>?$/})
        mail = if include_images
          multipart_with_inline_images(subject,to_email_address,from_email_address,the_parts,message_id,include_images)
        else
          multipart_alternative_without_images(subject,to_email_address,from_email_address,the_parts,message_id,include_images)
        end
        mail.header['Return-Path'] = MailManager.bounce['email_address']
        mail.header['X-Bounce-Guid'] = message_id if message_id
        set_mail_settings(mail)
        mail.deliver!
        Rails.logger.info "Sent mail to: #{to_email_address}"
        Rails.logger.debug mail.to_s
      end

      def set_mail_settings(mail)
        delivery_method = ActionMailer::Base.delivery_method
        delivery_method = delivery_method.eql?(:letter_opener) ? :test : delivery_method
        mail.delivery_method delivery_method
        # letter opener blows up!
        # Ex set options!
        #         mail.delivery_method.settings.merge!( {
        #   user_name: 'bobo',
        #   password: 'Secret1!',
        #   address: 'mail.lnstar.com',
        #   domain: 'mail.lnstar.com',
        #   enable_starttls_auto: true,
        #   authentication: :plain,
        #   port: 587
        # } )

        mail.delivery_method.settings.merge!(
          (case delivery_method 
           when :smtp then ActionMailer::Base.smtp_settings
           # :nocov:
           when :sendmail then ActionMailer::Base.sendmail_settings
           # :nocov:
           else
             {}
           end rescue {})
        )
      end
    
      def inline_attachment(params, &block)
        params = { :content_type => params } if String === params
        params = { :disposition => "inline",
                   :transfer_encoding => "base64" }.merge(params)
        params[:headers] ||= {}
        params[:headers]['Content-ID'] = params[:cid]
        params
      end

      def image_mime_types(extension)
        # :nocov:
        case extension.downcase
          when 'bmp' then 'image/bmp'
          when 'cod' then 'image/cis-cod'
          when 'gif' then 'image/gif'
          when 'ief' then 'image/ief'
          when 'jpe' then 'image/jpeg'
          when 'jpeg' then 'image/jpeg'
          when 'jpg' then 'image/jpeg'
          when 'png' then 'image/png'
          when 'jfif' then 'image/pipeg'
          when 'svg' then 'image/svg+xml'
          when 'tif' then 'image/tiff'
          when 'tiff' then 'image/tiff'
        end
        # :nocov:
      end
      
      def get_extension_from_data(image_data)
        if defined?(MiniMagick)
          MiniMagick::Image.read(image_data)[:format] || ''
        elsif defined?(Magick)
          # :nocov: currently on ly mini_magick is tested
          Magick::Image.from_blob(image_data).first.format || ''
          # :nocov:
        else
          ''
        end
      rescue => e
        ''
      end
    
      def inline_html_with_images(html_source)
        parsed_data = html_source.split(/(<\s*img[^>]+src\s*=\s*["'])([^"']*)(["'])/i)
        images = Array.new
        final_html = ''
        image_errors = ''
        parsed_data.each_with_index do |data,index|
          if(index % 4 == 2)
            image = Hash.new()
            image[:cid] = Base64.encode64(data).gsub(/\s*/,'').reverse[0..59]
            final_html << "cid:#{image[:cid]}"
            #only attach new images!
            next if images.detect{|this_image| this_image[:cid].eql?(image[:cid])}
            begin
              image[:content] = fetch(data)
            rescue => e
              image_errors += "Couldn't fetch url '#{data}'<!--, #{e.message} - #{e.backtrace.join("\n")}-->\n"
            end
            image[:filename] = filename = File.basename(data)
            extension = filename.gsub(/^.*\./,'').downcase
            Rails.logger.debug "Fetching Image for: #{filename} #{image[:content].to_s[0..30]}"
            extension = get_extension_from_data(image[:content]) if image_mime_types(extension).blank?
            image_errors += "Couldn't find mime type for #{extension} on #{data}" if image_mime_types(extension).blank?
            image[:content_type] = image_mime_types(extension)
            images << image
          else
            final_html << data
          end
        end
        raise image_errors unless image_errors.eql?('')
        [final_html,images]
        # related_part = Mail::Part.new do 
        #   body final_html
        # end
        # images.each do |image|
        #   related_part.part inline_attachment(image)
        # end
        # related_part.content_type = 'multipart/related'
        # related_part

        # related_part = Mail::Part.new do
        #   content_type 'multipart/related'
        #   # content_type 'text/html; charset=UTF-8'
        #   # body final_html
        # end
        # related_part.parts << Mail::Part.new do
        #   content_type 'text/html; charset=UTF-8'
        #   body final_html
        # end
        # images.each do |image|
        #   related_part.attachments[image[:filename]] = image[:body]
        # end
        # related_part.content_type = 'multipart/related'
        # related_part.parts.first.content_type = 'text/html; charset=UTF-8'
        # related_part.parts.first.header['Content-Disposition'] = 'inline'

      end

      # the following may be useful someday... but curb stopped working ... sooooo...
      #def local_ips
      #  `/sbin/ifconfig`
      #end

      #def request_local?(uri_str)
      #  uri = URI.parse(uri_str)
      #  ip_address = `host #{uri.host}`.gsub(/.*has address ([\d\.]+)\s.*/m,"\\1")
      #  local_ips.include?(ip_address)
      #rescue => e
      #  false
      #end
    
      def fetch(uri_str, limit = 10)
        uri = URI.parse(uri_str)
        if uri.scheme.eql?('file')
          File.read(uri_str.gsub(%r#^file://#,''))
        else
          uri.read
        end
      end
    end
  end
end



