Feature: As a Dev
         I would like to be able to create multiple Chef environments for grouping instances

  Scenario: Create a new environment
    Given I am in the "TeamName" team
    And I am on the "TeamName" team page
    When I click "Create a new environment"
    And I request team environment
    Then I should see the team environment in team page
