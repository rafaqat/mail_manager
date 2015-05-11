Feature: view messages for mailings
  In order to see messages and their statuses for mailings
  As a valid user
  I want to search for messages by mailing and status 

  Background:
    Given I am logged in and authorized for everything
      And a mailing with subject "Buy my junk!" exists
      And a mailing list named "Funk" exists
      And the mailing with subject "Buy my junk!" is set to send to "Funk" 
      And a contact named "Bobo Clown" exists with email_address "bobo@example.com"
      And contact "Bobo Clown" is subscribed to "Funk"
      And I set jobs to run immediately
      And the mailing with subject "Buy my junk!" is scheduled
  
  @javascript
  Scenario:
    When I go to the mailings page
     And I follow "Messages"
     And I select "Any Status" from "Status"
    Then I should see "bobo@example.com"
    When I select "Pending" from "Status"
    Then I should not see "bobo@example.com"
    When I select "Sent" from "Status"
    Then I should see "bobo@example.com"
    When I select "Failed" from "Status"
    Then I should not see "bobo@example.com"
    When I select "Any Status" from "Status"
    Then I should see "bobo@example.com"
     
