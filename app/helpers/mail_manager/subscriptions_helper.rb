module MailManager
  module SubscriptionsHelper
    def contactable_subscriptions_selector(contactable_form)
      render :partial => 'mail_manager/subscriptions/subscriptions', :locals => {:contactable_form => contactable_form}
    end
  end
end
