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

require 'net/http'
require 'uri'
require "base64"

module MailMgr
  class Mailer < ActionMailer::Base
    def unsubscribed(message,subscriptions)
      @contact = message.contact
      @recipients = @contact.email_address
      @from = message.from_email_address
      @message = message
      @mailing_lists = subscriptions.reject{|subscription| subscription.mailing_list.nil?}.
        collect{|subscription| subscription.mailing_list.name}
      @subject = "Unsubscribed from #{@mailing_lists.join(',')} at #{Conf.site_url}"
      Rails.logger.debug "Really Sending Unsubscribed from #{@mailing_lists.first} to #{@contact.email_address}"
    end

    def double_opt_in(contact)
      @contact = contact
      @recipients = @contact.email_address
      @subject = "Confirm Newsletter Subscription at #{Conf.site_url}"
      @from = Conf.newsletter_signup_email_address
      @mailing_list_names = contact.subscriptions.map(&:mailing_list).map(&:name).join(', ')
      @headers    = {'Return-Path' => Conf.mail_mgr_bounce['email_address']}
    end

    def message(message)
      mail(message.subject,message.email_address_with_name,message.from_email_address,
        message.parts,message.guid,message.mailing.include_images?)
    end
  
    def mail(subject,to_email_address,from_email_address,the_parts,message_id=nil,include_images=true)
      include_images = (include_images and !Conf.mail_mgr_dont_include_images_domains.detect{|domain| 
        to_email_address.strip =~ /#{domain}>?$/})
      @recipients = to_email_address
      @subject    = subject
      @from       = from_email_address
      @sent_on    = Time.now()
      @headers    = {'Return-Path' => Conf.mail_mgr_bounce['email_address']}
      @headers['X-Bounce-Guid'] = message_id if message_id
    
      TMail::HeaderField::FNAME_TO_CLASS.delete 'content-id'
    
      @content_type = 'multipart/alternative'
      the_parts.each do |type,content|
        Rails.logger.warn "Adding Part: #{type} - #{content[0..40]}"
        if type.eql?('text/html') and include_images
          parts << inline_html_with_images(content)
        else
          part :content_type => type, :body => content
        end
      end
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
    end
    
    def get_extension_from_data(image_data)
      identify_string = ''
      identify_string = ''
      file = Tempfile.new('guess_image_format')
      file.write image_data; 
      file.close
      identify_string = `identify #{file.path}`
      file.close!
      identify_string.split(/\s+/)[1].to_s.downcase
    end
  
    def inline_html_with_images(html_source)
      regex = /(<\s*img[^>]+src\s*=\s*["'])([^"']*)(["'])|(<\s*table[^>]+background\s*=\s*["'])([^"']*)(["'])/i
      parsed_data = html_source.split(regex)
      images = Array.new
      final_html = ''
      image_errors = ''
      parsed_data.each_with_index do |data,index|
        if(index % 4 == 2)
          image = Hash.new
          image[:cid] = Base64.encode64(data).gsub(/\s*/,'').reverse[0..59]
          final_html << "cid:#{image[:cid]}"
          #only attach new images!
          next if images.detect{|this_image| this_image[:cid].eql?(image[:cid])}
          begin
            image[:body] = fetch(data)
          rescue => e
            image_errors += "Couldn't fetch url '#{data}'<!--, #{e.message} - #{e.backtrace.join("\n")}-->\n"
          end
          image[:filename] = data.gsub(/^.*\//,'')
          extension = ''#data.gsub(/^.*\./,'').downcase
          extension = get_extension_from_data(image[:body]) if image_mime_types(extension).blank?
          image_errors += "Couldn't find mime type for #{extension} on #{data}" if image_mime_types(extension).blank?
          image[:content_type] = image_mime_types(extension)
          images << image
        else
          final_html << data
        end
      end
      raise image_errors unless image_errors.eql?('')
      related_part = ActionMailer::Part.new({}) 
      related_part.part :content_type => "text/html",
        :body => final_html

      images.each do |image|
          related_part.part inline_attachment(image)
      end
      related_part.content_type = 'multipart/related'
      related_part
    end
  
    def fetch(uri_str, limit = 10)
      # You should choose better exception.
      raise ArgumentError, 'HTTP redirect too deep' if limit == 0

      response = Net::HTTP.get_response(URI.parse(uri_str))
      case response
      when Net::HTTPSuccess     then response.body
      when Net::HTTPRedirection then fetch(response['location'], limit - 1)
      else
        response.error!
      end
    end
  end
end



