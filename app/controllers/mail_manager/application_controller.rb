module MailManager
  class ApplicationController < ApplicationController
    load_and_authorize_resource if respond_to? :load_and_authorize_resource
  end
end
