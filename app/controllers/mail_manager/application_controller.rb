require 'cancan'
require 'dynamic_form'
module MailManager
  class ApplicationController < ::ApplicationController
    layout MailManager.layout
    load_and_authorize_resource unless: :public_path?
    helper :'mail_manager/layout'
    helper :'mail_manager/subscriptions'

    def public_path?
      MailManager.public_path?(request.path)
    end
  end
end
