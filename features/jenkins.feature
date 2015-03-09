Feature: Jenkins
  In order to test my code
  As a team member
  I want to manage my Jenkins server

  Background:
    Given AWS has information about machines
    And queues and topics are configured
    And I am in the "Pantry Team" team
    And "Pantry Team" team has a "CI" environment "Pantry"

  @javascript
  Scenario: Start jenkins server
    Given instance role for Jenkins Server
    And I request jenkins server
    Then I should see "Pantry Team's jenkins server"
    And I should see a flash message with "Jenkins server request succeeded."
    And the instance build should start

  Scenario: Team should not be duplicated
    Given I am in the "TestTeam" team
    And "TestTeam" team has a "CI" environment "Pantry"
    And "TestTeam" team has a "WIP" environment "WIPPantry"
    When I am on the new server page
    Then team "TestTeam" should not be duplicated

  Scenario: Skips team with terminated and running jenkins_server
    Given I am in the "TestTeam" team
    And "TestTeam" team has a "CI" environment "Pantry"
    And I am on the new server page
    Then I choose "TestTeam" team
    When I have a terminated jenkins server
    And I am on the new server page
    Then I choose "TestTeam" team
    When I have a jenkins server
    And I am on the new server page
    Then I should not see "TestTeam"

  @javascript
  Scenario: Create Jenkins slave
    Given I have a jenkins server
    And instance role for Jenkins Slave
    When I click "Jenkins"
    Then I should see the server listing
    When I click on the server ID
    Then I should see "Create a new slave"

    When I click "Teams"
    And I click "Pantry Team"
    Then I should see "Create a new slave"
    When I request new slave
    Then I should be redirected to the Jenkins server page
    And I should see the slaves listing

    When the instance is created with ip "123.456.7.8"
    Then I should see "Ready" after page is updated
    And I should not see "Booting"

  Scenario: Starting a shut down slave
    Given I have a jenkins server
    And I have a jenkins slave
    And the slave is shut down
    When I go into Jenkins slave page
    And I click "Start"
    And the slave should be starting

  Scenario: Shutting down a slave
    Given I have a jenkins server
    And I have a jenkins slave
    And the instance is ready
    When I go into Jenkins slave page
    And I click "Shut down"
    Then I should see "Shutting down has started"

  @javascript
  Scenario: Resizing jenkins server
    Given flavors are configured
    And I have a jenkins server
    When I go into Jenkins server page
    And I click on jenkins server size
    And I choose "m3.xlarge" flavor
    Then "m3.xlarge" instance details should be present
    When I click on "Resize"
    Then I should see "Resizing" after page is updated
    And request for resize should be sent

  @javascript
  Scenario: Resizing jenkins slave
    Given flavors are configured
    And I have a jenkins server
    When I have a jenkins slave
    And I go into Jenkins slave page
    And I click on jenkins server size
    And I choose "c3.2xlarge" flavor
    Then "c3.2xlarge" instance details should be present
    When I click on "Resize"
    Then I should see "Resizing" after page is updated
    And request for resize should be sent

  Scenario: Delete a slave
    Given I have a jenkins server
    And I have a jenkins slave
    When I go into Jenkins slave page
    And I destroy Jenkins slave
    Then I should be redirected to the Jenkins server page
    And I should see a flash message with "Jenkins slave deletion request succeeded"
    And I click on the jenkins slave
    And I should see "Destroy action sent. This slave is not usable anymore."

    When slave is deleted
    And I click on "Go back to the Jenkins server"
    Then I should not see slave in listing

    Given I have a jenkins slave
    And the jenkins slave is protected from termination
    When I go into Jenkins slave page
    Then I should not see "Destroy"

  @javascript
  Scenario: Attempting to shut down, destroy another team's slave
    Given I have a jenkins server
    And I have a jenkins slave
    And the instance is ready
    When I go into Jenkins slave page
    Then I should see "Shut down" button after page is updated
    And I should see "Destroy" button

    When the slave does not belong to my team
    When I go into Jenkins slave page
    Then I should not see "Shut down" button
    And I should not see "Destroy" button

  Scenario: a team can create only one server
    Given I have a jenkins server
    When I click "Jenkins"
    Then I should not see "Create a new server"
