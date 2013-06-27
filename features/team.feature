Feature: Managing Teams
Scenario: Adding a new Team
	Given I am on the teams page 
    When An agent creates a new team named "TeamName"
    Then I should be on team page
    And I should see "TeamName"
    
    When I click "Teams"
    Then I should see "TeamName"
    
