Feature: Manage Contacts
  In order to value
  As a role
  I want feature

  Background:
    Given a contact named "Bob Dole" exists with email_address "bob@example.com"
    And I am logged in and authorized for everything

  Scenario: Search Contacts that exist
    When I go to the contacts page
    And I fill in "term" with "bob"
    And I press "Search"
    Then I should be on the contacts page
    And I should see "bob@example.com"
    
  Scenario: Search Contacts that don't exist
    When I go to the contacts page
    And I fill in "term" with "sam"
    And I press "Search"
    Then I should be on the contacts page
    And I should not see "bob@example.com"
  
  @javascript
  Scenario: Search for contacts by mailing list and status
   Given a contact named "Babs Dole" exists with email_address "babs@example.com"
     And a mailing list named "Peeps" exists
     And the contact named "Babs Dole" is subscribed to "Peeps"
    When I go to the contacts page
    Then I should see "bob@example.com"
     And I should see "babs@example.com"
    When I select "Peeps" from "Mailing List"
     And I select "Any" from "Status"
     And I press "Search"
    Then I should see "babs@example.com"
     And I should not see "bob@example.com"
    When I select "Pending" from "Status"
     And I press "Search"
    Then I should not see "babs@example.com"
     And I should not see "bob@example.com"
