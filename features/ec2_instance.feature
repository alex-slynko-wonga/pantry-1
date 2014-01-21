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

    When I check my profile page
    Then I should see machine info

  @javascript
  Scenario: Creating a new instance with custom AMI
    Given I am a superadmin
    And I am in the "Pantry" team
    And ami-123 "TestWindows" exists in AWS
    And I am on the ec2 instance new page
    When I enter all required data for ec2
    And I entered ami-123 in custom ami field
    #    Then I should see "TestWindows"
    When I create machine
    Then I should see a flash message with "Ec2 Instance request succeeded."
    And an instance with ami-123 build should start

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

    Given I have at least one EC2 in the team
    And the instance is protected
    When I am on instance page
    Then I should not see "Destroy"


  @javascript
  Scenario: Shutting down an instance
    Given I have at least one EC2 in the team
    And the instance is ready
    When I am on instance page
    When I click "Shut down"
    Then I should see "Shutting down has started"

  @javascript
  Scenario: Starting a shut down instance
    Given I have at least one EC2 in the team
    And the instance is shutdown
    When I am on instance page
    And I click "Start"
    Then I should see "Starting instance"
    And I should see "Starting"

  @javascript
  Scenario: Attempting to shut down or destroy another team's instances
    Given an EC2 instance
    And the instance is ready
    And I am on instance page
    Then I should not see "Shut down" button
    And I should not see "Destroy" button
