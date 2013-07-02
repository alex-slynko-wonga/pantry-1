Feature: Managing Teams
Scenario: Adding a new Team
	Given I am on the teams page 
    When An agent creates a new team named "TeamName"
    Then I should be on team page
    And I should see "TeamName"
    
    When I click "Teams"
    Then I should see "TeamName"

Scenario: Updating existing team
	Given there exists a team named "TeamName"
	And I am on the teams page
	And I click on "TeamName"
	And I click on "edit"
	And I update team "TeamName" with name "NewName"
	Then I should see "NewName"
