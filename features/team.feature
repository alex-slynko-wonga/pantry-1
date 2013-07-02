Feature: Managing Teams
Scenario: Adding a new Team
	Given I am on the teams page 
    When An agent creates a new team named "TeamName"
    Then I should be on team page
    And I should see "TeamName"
    

Scenario: Updating existing team
	Given there exists a team named "TeamName"
	When I update team "TeamName" with name "NewName"
	Then I should see "NewName"
