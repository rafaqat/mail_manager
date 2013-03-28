module MailManager
  class TestMessage < Message
    default_scope :order => "status_changed_at desc"
    named_scope :ready, :conditions => ["status=?", 'ready']
    def email_address
      self[:test_email_address]
    end

    def email_address_with_name
      "\"Test Guy\" <#{email_address}>"
    end

    def default_status
      'ready'
    end
    def generate_guid
      update_attribute(:guid,
        "test-#{self.id}-#{Digest::SHA1.hexdigest("test-#{self.id}-#{Conf.mail_manager_secret}")}")
    end

    def subscription
      Subscription.new(self)
    end

    def valid_statuses
      ['ready'] + super
    end
    class Subscription
      def initialize(test_message)
        @test_message = test_message
      end
      def contact
        Contact.new(@test_message)
      end
    end
    class Contact
      def initialize(test_message)
        @test_message = test_message
      end
      def full_name
        "#{first_name} #{last_name}".strip
      end
      def first_name
        'Test'
      end
      def last_name
        'Guy'
      end
      def email_address
        @test_message.email_address
      end
    end
  end
end
