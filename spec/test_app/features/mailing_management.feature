Feature: Mailing Management
	In order send mailings to my mailing list
	As a valid user
	I want to create, modify, schedule and cancel mailings
	
	Background:
    Given I am logged in and authorized for everything
      And a mailing with subject "Buy my junk!" exists
      And I clear the job queue
      And I set jobs to be delayed
	
	Scenario: schedule a mailing
	  When I go to the mailings page
	   And I follow "Schedule"
	  Then I should see "Buy my junk!"
     And the mailing with subject "Buy my junk!" should be scheduled
	   And I should see "scheduled"
	   And I should see "Edit"
	   And I should see "Cancel"

  Scenario: Cancel a mailing
   Given the mailing with subject "Buy my junk!" is scheduled
    When I go to the mailings page
     And I follow "Cancel"
    Then I should see "Buy my junk!"
     And the mailing with subject "Buy my junk!" should be canceled
     And I should see "pending"
     And I should see "Send Test"
     And I should see "Edit"
  
  # need to create a valid mailable
  @wip
  Scenario: send a test message for mailing
    When I go to the mailings page
     And I follow "Send Test"
     And I fill in "test_email_addresses" with "test@example.com"
     And I press "Send Test Email"
    Then I should see "Buy my junk!"
     And I should see "Send Test"
     And I should see "Edit"
     And an email is sent to "test@example.com" with subject "Buy my junk!"
