Feature: Jenkins
  In order to test my code
  As a team member
  I want to manage my Jenkins server

  Background:
    Given AWS has information about machines

  @javascript
  Scenario: Start jenkins server
    Given I am in the "Pantry Team" team
    And I request jenkins server
    Then I should see "Pantry Team's jenkins server"
    And an instance build should start
    