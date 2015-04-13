Feature: Manage Subscriptions
  In order to have a list of email addresses to send messages to
  As an administrator
  I want to manage a contact's subscriptions
    
  Background:
    Given a mailing with subject "Mailing" exists
    And a mailing list named "List1" exists
    And the mailing list named "List1" is one of mailing "Mailing"'s mailing_lists
    And a mailing list named "List2" exists
    And the mailing list named "List2" is one of mailing "Mailing"'s mailing_lists
    And a mailing list named "List3" exists
    And a mailing list named "List4" exists
    And a contact named "Bob Dole" exists with email_address "bob@example.com"
    And contact "Bob Dole" is subscribed to "List1, List3"
  
  Scenario: Unsubscribe sends an email
   When the mailing with subject "Mailing" is scheduled 
    # this is done when the job is created by scheduling
    # And I deliver the mailing with subject "Mailing"
    And contact "Bob Dole" uses the unsubscribe link
   Then contact "Bob Dole" should receive an email saying he unsubscribed
    And contact "Bob Dole" should be unsubscribed from "List1"
    And contact "Bob Dole" should be subscribed to "List2" with the "pending" status
    And contact "Bob Dole" should be unsubscribed from "List3"
    And contact "Bob Dole" should be subscribed to "List4" with the "pending" status
    
  Scenario: Unsubscribe from test message
   When I go to the mailings page
    And I follow "Send Test"
    And I fill in "Test Email Address" with "bob@example.com"
    And I press "Send Test Email"
    And I use the test email's unsubscribe link
   Then I should see "unsubscribed"
    And I should see "bob@example.com"
    And I should see "Test Mailing List"

  Scenario: Unsubscribe from test message with no contact/subscription
   When I go to the mailings page
    And I follow "Send Test"
    And I fill in "Test Email Address" with "bobo@example.com"
    And I press "Send Test Email"
    And I use the test email's unsubscribe link
   Then I should see "unsubscribed"
    And I should see "bobo@example.com"
    And I should see "Test Mailing List"

  Scenario: Unsubscribe by email address
   When I go to the unsubscribe by email address page
    And I fill in "Email Address" with "bob@example.com"
    And I press "Unsubscribe"
   Then I should see "Unsubscribed"
    And I should see "bob@example.com"
    And contact "Bob Dole" should be unsubscribed from "List1"
    And contact "Bob Dole" should be subscribed to "List2" with the "pending" status
    And contact "Bob Dole" should be unsubscribed from "List3"
    And contact "Bob Dole" should be subscribed to "List4" with the "pending" status

  Scenario: Unsubscribe with invalid guid
   When I try to unsubscribe with an invalid guid
   Then I should be on the unsubscribe by email address page
    And I should see "We did not recognize that unsubscribe url! Please try unsubscribing with your email address." 
