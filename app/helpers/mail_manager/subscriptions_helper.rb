module MailManager
  module SubscriptionsHelper
    def contactable_subscriptions_selector(contactable_form, default_unsubscribe_status)
      render :partial => 'mail_mgr/subscriptions/subscriptions', :locals => {:contactable_form => contactable_form,
        :unsubscribed_status => default_unsubscribe_status}
    end
  end
end
