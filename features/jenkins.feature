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
    Given I request jenkins server
    Then I should see "Pantry Team's jenkins server"
    And I should see a flash message with "Jenkins server request succeeded."
    And an instance build should start

  @javascript
  Scenario: Create Jenkins slave
    Given I have a jenkins server
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
    And the jenkins slave is protected
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
