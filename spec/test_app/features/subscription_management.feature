Feature: Manage Subscriptions
  In order to have a list of email addresses to send messages to
  As an administrator
  I want to manage a contact's subscriptions
    
  Scenario: Unsubscribe sends an email
    Given a mailing with subject "Mailing" exists
    And a mailing list named "List1" exists
    And the mailing list named "List1" is one of mailing "Mailing"'s mailing_lists
    And a mailing list named "List2" exists
    And the mailing list named "List2" is one of mailing "Mailing"'s mailing_lists
    And a mailing list named "List3" exists
    And a mailing list named "List4" exists
    And a contact named "Bob Dole" exists with email_address "bob@example.com"
    And contact "Bob Dole" is subscribed to "List1, List3"
    
