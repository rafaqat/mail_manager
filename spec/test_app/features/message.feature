Feature: Messages are tied to mailings even without subscriptions
  In order to have relations with non-subscribed contacts
  As an administrator
  I want to send messages for contacts that aren't subscribed
  
  Scenario:
    Given I am logged in and authorized for everything
    And a mailing with subject "Mailing" exists
    And a contact named "Bob Dole" exists with email_address "bob@example.com"

  
