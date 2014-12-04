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
    And "teamname" team has an "INT" environment with name "TEST"
    And I request an instance named "instanceName"
    Then I should see "instanceName"
    And I should see "Booting"
    Then I should see "History"
    And I should see my name near "Ec2Boot"
    And I should see a flash message with "Ec2 Instance request succeeded."
    And I should not see "Instance role:"
    And an instance build should start

    When an instance is created with ip "123.456.7.8"
    And I am on instance page
    Then I should see "Ready" after page is updated
    And I should see my name near "Bootstrap"
    And I should see "123.456.7.8"
    And I should see "TEST (INT)"
    And I should receive email

    When I check my profile page
    Then I should see machine info

  @javascript
  Scenario: Creating a new instance without team_id
    Given I am in the "first" team
    And "first" team has an "INT" environment with name "custom1"
    And I am in the "second" team
    And "second" team has an "WIP" environment with name "custom2"
    When I request an EC2 instance
    And I choose "custom1" environment
    Then I should see "Team: first" after page is updated
    When I choose "custom2" environment
    Then  I should see "Team: second" after page is updated
    But I should not be able to choose "first CI" environment

  @javascript
  Scenario: Creating a new instance for specific team
    Given I am in the "first" team
    And "first" team has an "INT" environment with name "custom1"
    And I am in the "second" team
    And "second" team has an "WIP" environment with name "custom2"
    When I request an EC2 instance for team "first"
    And I choose "custom1" environment
    Then I should see "Team: first"
    But I should not be able to choose "custom2" environment
    And I should not be able to choose "first CI" environment

  @javascript
  Scenario: Creating a new instance with instance role
    Given "MyInstanceRole" instance role
    And I am in the "TeamName" team
    And "TeamName" team has an "INT" environment with name "TEST"
    When I request an EC2 instance
    And I enter all required data for ec2
    And I choose "MyInstanceRole" instance role
    Then I should not see "Run list"
    And I should not see "Ami"
    And I should not see "Flavor"
    And I should not see "Subnet"
    And I should not see "Security group ids"
    When I click on "Create"
    Then I should see "Instance role: MyInstanceRole"

  @javascript
  Scenario: Cannot select disabled instance role
    Given "MyInstanceRole" instance role is disabled
    And I am in the "TeamName" team
    And "TeamName" team has an "INT" environment with name "TEST"
    When I request an EC2 instance
    Then I should not be able to choose "MyInstanceRole" instance role

  Scenario: Create instance like existing
    Given I am in the "Pantry" team
    And I have "m1.large" instance
    When I am on instance page
    And I click on "Create machine like this"
    Then I should see new ec2 instance form with prefilled values

  @javascript
  Scenario: Show info about instance price per hour, RAM and CPU
    Given I am in the "teamname" team
    And flavors are configured
    And I request an EC2 instance
    When I choose "m3.xlarge" flavor
    Then "m3.xlarge" instance details should be present

  @javascript
  Scenario:
    Given AWS pricing is broken
    And I am in the "TeamName" team
    And "TeamName" team has an "INT" environment with name "TEST"
    And flavors are configured
    When I request an EC2 instance
    And I enter all required data for ec2
    And I choose "m3.xlarge" flavor
    Then I should not see "Price windows:"
    And I should not see "Virtual cores:"
    When I click on "Create"
    Then I should see "Booting"

  Scenario: Bootstrapping event
    Given I have an EC2 instance in the team
    And the instance is ready
    When I receive "bootstrap" event
    Then server should respond with success

  Scenario: Unable to bootstrap an instance with invalid api key
    Given I have an EC2 instance in the team
    And the instance is ready
    When I receive "bootstrap" event with wrong api key
    Then server should respond with fail

  Scenario: Unable to bootstrap an instance without valid permissions
    Given I have an EC2 instance in the team
    And the instance is ready
    When I receive "bootstrap" event without api key permissions
    Then server should respond with fail

  @javascript
  Scenario: Machine status
    Given I have an EC2 instance in the team
    And instance load is "2.42"
    When I am on instance page
    Then I should see "2.42" after page is updated

  @javascript
  Scenario: Cannot select more than four security groups
    Given I am in the "Pantry" team
    And I visit ec2 instance new page
    And I enter all required data for ec2
    And I enter "" in name field
    When I select four security groups
    Then I should not be able to add a fifth security group
    When I click on "Create"
    Then I should see "Name can't be blank"
    And I should not be able to add a fifth security group

  @javascript
  Scenario: Destroying an instance
    Given I have an EC2 instance in the team
    When I am on instance page
    And I destroy an instance
    Then I should see "Terminating"
    And I should see a flash message with "Ec2 Instance deletion request success"
    And instance destroying process should start

    When an instance is destroyed
    And I am still on instance page
    Then I should see that instance is destroyed

    When I am on the team page
    Then I should not see machine info

  Scenario: Destroying an protected instance
    Given I have an EC2 instance in the team
    And the instance is protected
    When I am on instance page
    Then I should not see "Destroy"

  Scenario: Destroying an instance from instance list without redirecting to 'show' page
    Given I have an EC2 instance in the team
    When I am on the team page
    And I click on "Trash" icon
    Then I should see "Terminating"
    And I should see a flash message with "Ec2 Instance deletion request success"
    And instance destroying process should start
    And I should see "Team Members"
    And I should see "Instances"

  @javascript
  Scenario: Cleaning an instance
    Given I have an EC2 instance in the team
    And the instance is booting
    When I am on instance page
    And I cleanup an instance
    And I should see a flash message with "Ec2 Instance cleanup request success"
    And instance cleaning process should start

  @javascript
  Scenario: Start cleaning process for terminated machine
    Given I have an EC2 instance in the team
    And the instance is terminated
    When I receive "bootstrap" event
    Then server should respond with success
    And instance cleaning process should start

  @javascript
  Scenario: Shutting down an instance
    Given I have an EC2 instance in the team
    And the instance is ready
    When I am on instance page
    When I click "Shut down"
    Then I should see a flash message with "Shutting down has started"
    And shut down request should be sent
    When machine is shut down
    Then I should see "Shutdown" after page is updated

    When I click "Start"
    Then I should see a flash message with "Starting instance"
    And I should see "Starting"
    And start request should be sent

    When machine is started
    Then I should see "Ready" after page is updated

  @javascript
  Scenario: Attempting to shut down or destroy another team's instances
    Given an EC2 instance
    And the instance is ready
    And I am on instance page
    Then I should not see "Shut down" button
    And I should not see "Destroy" button

  @javascript
  Scenario: Show info about instance on show form
   Given I have small EC2 instance in the team
   And flavors are configured
   When I am on instance page
   And I click on instance size
   When I choose "m3.xlarge" flavor
   Then "m3.xlarge" instance details should be present

  @javascript
  Scenario: Resize machine
    Given I have small EC2 instance in the team
    When I am on instance page
    And I click on instance size
    And I set m1.large as new size
    Then I should see "Resizing" after page is updated
    Then request for resize should be sent
    But I should not see "m1.large"

    When machine is resized with "m1.large"
    Then I should see "m1.large" after page is updated

    When machine is started
    Then I should see "Ready" after page is updated

  Scenario: Shutdown and Start a single instance
    Given I have an EC2 instance in the team
    And the instance is ready
    When I am on the team page
    And I click on "Shutdown"
    Then I should see "Shutting down"
    And shut down request should be sent
    When machine is shut down
    Then option "Start" should be present near instance

    When I click on "Start"
    Then I should see "Starting"
    And start request should be sent
    When machine is started
    Then option "Shutdown" should be present near instance
    And I should see "Ready"

  @javascript
  Scenario: Update instances statuses without page refresh
    Given I have an EC2 instance with "TEST1" name in the team
    And I have an EC2 instance with "TEST2" name in the team
    When I am on the team page
    Then I should see "Ready" status near "TEST1" name
    Then I should see "Ready" status near "TEST2" name

    When the instance is terminated
    Then I should see "Terminated" status near "TEST2" name after 5 seconds
    Then I should see "Ready" status near "TEST1" name




