Feature: Managing Teams
Scenario: Adding a new Team
	Given I am on the teams page 
    When An agent creates a new team named "Team"
    Then I expect to see "Team"
