Feature: Manage Contacts
  In order to value
  As a role
  I want feature


  Scenario: Search Contacts that exist
    Given a contact named "Bob Dole" exists with email_address "bob@example.com"
    And I am logged in and authorized for everything
    When I go to the contacts page
    And I fill in "term" with "bob"
    And I press "Search"
    Then I should be on the contacts page
    And I should see "bob@example.com"
    
  Scenario: Search Contacts that don't exist
    Given a contact named "Bob Dole" exists with email_address "bob@example.com"
    And I am logged in and authorized for everything
    When I go to the contacts page
    And I fill in "term" with "sam"
    And I press "Search"
    Then I should be on the contacts page
    And I should not see "bob@example.com"
  
