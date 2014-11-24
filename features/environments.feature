Feature: Multiple environments
  As a Dev
  To group instances
  I would like to be able to create multiple Chef environments

  Scenario: Create a new environment from the team page
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

  Scenario: Create  a new environment from the EC2 Instance page
    Given I am in the "TeamName" team
    And queues and topics are configured
    And I request an EC2 instance for team "TeamName"
    When I click "Create a new environment"
    And I select "WIP" as environment type
    And name it as "Ours"
    And I save environment
    Then a new chef environment should be requested
    When environment is created
    Then I should see "Create EC2 Instance"
    When I request an EC2 instance for team "TeamName"
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

  Scenario: Update environment
    Given I am in the "teamname" team with "username" user
    And "teamname" team has an "INT" environment "TEST_INT"
    When I am on environment page
    And I update environment with name "NewName" and description "This is a test"
    Then I should see a flash message with "Environment updated successfully"
    And I should see "NewName"
    And I should see "This is a test"

  Scenario: Updating existing environment when the user is not in the given team
    Given the "teamname" team
    And "teamname" team has an "INT" environment "TEST_INT"
    When I am on environment page
    Then I should not see "Edit this environment"

  Scenario: Show only visible environments
    Given I am in the "teamname" team
    And "teamname" team has an "INT" environment "TEST_INT"
    And "teamname" team has an "RC" environment "TEST_RC"
    And "teamname" team has hidden "WIP" environment "TEST_WIP"
    When I am on the team page
    Then I should see "TEST_INT (INT)"
    And I should see "TEST_RC (RC)"
    And I should not see "TEST_WIP (WIP)"

  Scenario: Shutdown and Start all machines for selected environment
    Given I am in the "TeamName" team
    And AWS has information about machines
    And queues and topics are configured
    And "TeamName" team has an "INT" environment with name "TEST"
    And I have an EC2 instance in the team with environment "TEST"
    And the instance is ready
    And I have an EC2 instance in the team with environment "TEST"
    And the instance is ready
    And I am on environment page
    When I click on "Shutdown all instances"
    Then I should see "Shutting down"
    And shut down request should be sent 2 times
    When machines with environment "TEST" is shut down
    Then option "Start" should be present near instances with environment "TEST"

    When I click on "Start all instances"
    Then I should see "Starting"
    And start request should be sent 2 times
    When machines with environment "TEST" is start
    Then option "Shutdown" should be present near instances with environment "TEST"
