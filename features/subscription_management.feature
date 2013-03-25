Feature: Manage Subscriptions
  In order to have a list of email addresses to send messages to
  As an administrator
  I want to manage a contact's subscriptions
    
  Scenario: Unsubscribe sends an email
    Given a mailing: "Mailing" exists
    And a mailing_list: "List1" exists with name: "List1"
    And mailing_list: "List1" is one of mailing: "Mailing"'s mailing_lists
    And a mailing_list: "List2" exists with name: "List2"
    And mailing_list: "List2" is one of mailing: "Mailing"'s mailing_lists
    And a mailing_list: "List3" exists with name: "List3"
    And a mailing_list: "List4" exists with name: "List4"
    And a contact: "Bob" exists with email_address: "bob@example.com"
    And contact: "Bob" is subscribed to "List1, List3"
    And mailing: "Mailing"'s "deliver" should "be_true"
    
