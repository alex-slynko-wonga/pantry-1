Feature: Maintenance mode

  Scenario: Create instance
    Given site in "Very important" maintenance mode
    And I am in the "teamname" team
    And "teamname" team has a "CI" environment "testCI"
    And "teamname" team has a "INT" environment "test"
    Then I should not be able to create EC2 Instance
