require 'cancan'
require 'dynamic_form'
module MailManager
  class ApplicationController < ::ApplicationController
    layout MailManager.layout
    load_and_authorize_resource
    helper :'mail_manager/layout'
    helper :'mail_manager/subscriptions'
  end
end
