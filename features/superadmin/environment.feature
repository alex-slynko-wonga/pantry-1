Feature: Managing Environments

  As  a superadmin
  To help other people
  I want to manage their environments

  Background:
    Given I am a superadmin

  @javascript
  Scenario: Hide environments
    Given I am in the "teamname" team
    And "teamname" team has an "INT" environment "TEST_INT"
    When I am on environment page
    And I hide current environment
    And confirm it
    When I am on the teams page
    Then I should not see "TEST_INT (INT)"