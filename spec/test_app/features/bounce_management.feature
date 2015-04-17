Feature: Bounce Management
	In order track mail bounces
	As a valid user
	I want to list, dismiss and fail bounces

  Scenario: Paginate bounces
   Given 50 bounces exist
    When I go to the bounces page
    Then I should see "Previous"
     And I should see "Next"
    When I follow "Next"
