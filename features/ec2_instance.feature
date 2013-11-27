Feature: EC2 Instance
  In order to have all resources available
  As a team member
  I want to manage my EC2 instances

  Background:
    Given AWS has information about machines
    And queues and topics are configured

  @javascript
  Scenario: Creating a new instance
    Given I am in the "teamname" team
    And I request an instance named "instanceName"
    Then I should see "instanceName"
    And I should see "Booting"
    And I should see "pending"
    And I should see a flash message with "Ec2 Instance request succeeded."
    And an instance build should start

    When an instance is created with ip "123.456.7.8"
    Then I should see "Ready" after page is updated
    And I should see "123.456.7.8"

  @javascript
  Scenario: Machine status
    Given I have at least one EC2 in the team
    And instance load is "2.42"
    When I am on instance page
    Then I should see "2.42" after page is updated

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
    And I should see a flash message with "Ec2 Instance deletion request success"
    And instance destroying process should start

    When an instance is destroyed
    And I am still on instance page
    Then I should see that instance is destroyed

  @javascript
  Scenario: Shutting down an instance
    Given I have at least one EC2 in the team
    When I am on instance page
    And I shut down an instance
    Then I should see "Shutting down has started"
    And I should not see "Bootstrapped"
    And I should not see "Joined to Domain"
    And I should not see "Status check failed"
    And I should not see "CPU Utilization"

  Scenario: Starting a shut down instance
    Given I have at least one EC2 in the team
    And the instance is shut down
    When I am on instance page
    And I click "Start"
    Then I should see "Starting instance"    
    And I should see "Starting"
