Feature: EC2 Instance
  In order to have all resources available
  As a team member
  I want to manage my EC2 instances

  Background:
    Given AWS has information about machines

  @javascript
  Scenario: Creating a new instance
    Given I am in the "teamname" team
    And I request an instance named "instanceName"
    Then I should see "instanceName"
    And I should see "Booting"
    And an instance build should start

    When an instance is created
    And I am still on instance page
    Then I should see "Ready"
