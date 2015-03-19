Feature: Mailable Registration
	In order to have different things to email
	As an object
	I want be able to register as a mailable object
	
	Scenario: reusable mailables will be available when I create a new mailing
	  Given the following mlm mailable records
	    | name            | email_html                                                              | email_text      | reusable |
	    | June Newsletter | <head><title>June Newsletter</title><body>June Newsletter</body></html> | June Newsletter | true     |
	    | July Newsletter | <head><title>July Newsletter</title><body>July Newsletter</body></html> | July Newsletter | false    |
	  And an mlm mailing list exists with name: "Newsletter"
	  When I go to the new mlm mailing page
	  Then I should see "June Newsletter"
	  And I should not see "July Newsletter"
	  
	Scenario: a new raw mailable can be created when creating a new mailing
	  When I go to the new mlm mailing page 
	  And I select "New Mailable" from "mailing[mailable]"
	  And I fill in "mailable[name]" with "July Newsletter"
    And I fill in "mailable[email_html]" with "<head><title>June Newsletter</title><body>July Newsletter</body></html>"
    And I fill in "mailable[email_text]" with "July Newsletter"
    And I check "mailable[reusable]"
    Then an mlm mailable should exist with name: "July Newsletter", email_html: "<head><title>June Newsletter</title><body>July Newsletter</body></html>", email_text: "July Newsletter", reusable: true
