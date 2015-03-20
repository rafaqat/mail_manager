Feature: Mailing Management
	In order send mailings to my mailing list
	As a valid user
	I want to create, modify, schedule and cancel mailings
	
	Background:
	  #Given the following mlm mailable records
    #  | name            | email_html                                                              | email_text      | reusable |
    #  | June Newsletter | <head><title>June Newsletter</title><body>June Newsletter</body></html> | June Newsletter | false    |
    #  | July Newsletter | <head><title>July Newsletter</title><body>July Newsletter</body></html> | July Newsletter | true     |
    #And the following mlm mailing list records
    #  | name             |
    #  | The Mailing List |
	
  @wip
	Scenario: mailings are created by a valid user
	  When I go to the mlm mailings page
	  And I follow "New Mailing"
	  And I fill in "mailing[subject]" with "Fun Fun Fun July 2009"
	  And I select "July Newsletter" from "mailing[mailable]"
	  And I press "Save"
	  Then I should be on the mlm mailings page
	  And I should see "Fun Fun Fun"
	  And I should see "pending"
	  #And I should see "Send Test"
	  And I should see "Schedule"
	  And I should see "Edit"
	  And an mlm mailing should exist with subject: "Fun Fun Fun July 2009"
	  
  @wip
	Scenario: edit a mailing
	  Given the following mlm mailing records
	    | subject               |
	    | Fun Fun Fun July 2009 |
	  When I go to the mlm mailings page
	  And I follow "Edit"
	  And I fill in "mailing[subject]" with "Fun! Fun! Fun! July 2009"
	  And I press "Save"
	  And I should see "Fun! Fun! Fun! July 2009"
	  And I should see "pending"
	  And I should see "Send Test"
	  And I should see "Schedule"
	  And I should see "Edit"
	  
  @wip
	Scenario: schedule a mailing
	  Given the following mlm mailing records
	    | subject               |
	    | Fun Fun Fun July 2009 |
	  When I go to the mlm mailings page
	  And I follow "Schedule"
	  Then I should see "Fun Fun Fun"
	  And I should see "scheduled"
	  #And I should see "Send Test"
	  And I should see "Edit"
	  And I should see "Cancel"

  @wip
  Scenario: Cancel a mailing
    Given the following mlm mailing records
      | subject               | status    |
      | Fun Fun Fun July 2009 | scheduled |
    When I go to the mlm mailings page
    And I follow "Cancel"
    Then I should see "Fun Fun Fun"
    And I should see "pending"
    And I should see "Send Test"
    And I should see "Edit"
  
  @wip
  Scenario: send a test message for mailing
    Given the following mlm mailing records
      | subject               | status    | scheduled_at |
      | Fun Fun Fun July 2009 | scheduled | Time.now     |
    When I go to the mlm mailings page
    And I follow "Send Test"
    And I fill in "test_email_addresses" with "test@example.com"
    And I press "Send Test Email"
    Then I should see "scheduled"
    And I should see "Send Test"
    And I should see "Edit"
    And I should see "Cancel"
    And an email is sent to "test@example.com" with subject: "Fun Fun Fun July 2009"
