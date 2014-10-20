Feature: Multiple environments
  As a Dev
  To group instances
  I would like to be able to create multiple Chef environments

  Scenario: Create a new environment
    Given I am in the "TeamName" team
    And queues and topics are configured
    And I am on the "TeamName" team page
    When I click "Create a new environment"
    And I select "WIP" as environment type
    And name it as "Ours"
    And I save environment
    Then a new chef environment should be requested
    When environment is created
    When I request new ec2 instance
    Then I should be able to choose "Ours" from list of environments

  Scenario: Link to environment details from pages
    Given I have an EC2 instance in the team
    When I am on the team page
    And I click on environment human name
    Then I should see environment details
    And I should see a short table with the instance

    When I am on the user page
    And I click on environment human name
    Then I should see environment details
    And I should see a short table with the instance

    When I am on instance page
    And I click on environment human name
    Then I should see environment details
    And I should see a short table with the instance

  Scenario: Show all environments except CI
    Given I am in the "teamname" team
    And "teamname" team has an "INT" environment "TEST_INT"
    And "teamname" team has an "RC" environment "TEST_RC"
    And "teamname" team has a "WIP" environment "TEST_WIP"
    When I am on the team page
    Then I should see all environment human names except CI

  Scenario: Create new CI environment when it does not exist
    Given I am in the "teamname" team
    And "teamname" team does not have "CI" environment
    When I am on the team page
    Then I can create a new CI environment

  Scenario: Create new CI environment when it exists
    Given I am in the "teamname" team
    And "teamname" team has a "CI" environment "test"
    When I am on the team page
    Then I can not create a new CI environment