Feature: EC2 Instance
  In order to have all resources available
  As a team member
  I want to manage my EC2 instances

  Background:
    Given AWS has information about machines
    And queues are configured

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

  @javascript
  Scenario: Cannot select more than four security groups
    Given I visit ec2 instance new page
    When I select four security groups
    Then I should not be able to add a fifth security group

  @javascript
  Scenario: Destroying an instance
    Given I have at least one EC2 in the team
    When I am on instance page
    And I destroy an instance
    Then I should see "Terminating"
    And instance destroying process should start

    When an instance is destroyed
    And I am still on instance page
    Then I should see that instance is destroyed
