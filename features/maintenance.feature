Feature: Maintenance mode

  Scenario: Create instance
    Given site in "Very important" maintenance mode
    And I am in the "teamname" team
    And CI environment is ready
    Then I should not be able to create EC2 Instance
