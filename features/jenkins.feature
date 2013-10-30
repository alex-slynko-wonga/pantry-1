Feature: Jenkins
  In order to test my code
  As a team member
  I want to manage my Jenkins server

  Background:
    Given AWS has information about machines
    And queues and topics are configured

  @javascript
  Scenario: Start jenkins server
    Given I am in the "Pantry Team" team
    And I request jenkins server
    Then I should see "Pantry Team's jenkins server"
    And I should see a flash message with "Jenkins server request succeeded."    
    And an instance build should start

  @javascript
  Scenario: As a user I want to see the Jenkins server page with its salves
    Given I am in the "Pantry Team" team
    And I have a jenkins server
    And I have a jenkins slave
    When I click "Jenkins"
    Then I should see the server listing
    When I click the server ID
    Then I should see the slaves listing

  Scenario: As a user want to delete a slave
    Given I am in the "Pantry Team" team
    And I have a jenkins server
    And I have a jenkins slave
    When I go into Jenkins slave page
    And I click destroy
    Then I should be redirected to the Jenkins server page
    And I should see a flash message with "Jenkins slave deletion request succeeded"    
    And I click the jenkins slave
    And I should see "Destroy action sent. This slave is not usable anymore."