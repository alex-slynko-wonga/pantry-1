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
