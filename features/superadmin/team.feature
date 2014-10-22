Feature: Managing Teams

  As superadmin
  To help other people
  I want to manage their teams

  Background:
    Given I am a superadmin

  @javascript
  Scenario: Managing team users
    Given the "TeamName" team with "Test User" user
    And a LDAP user "Test Ldap User"
    And I am on the "TeamName" team page
    When I click on "Edit this team"
    And I click on remove cross near "Test User"
    And I search for "Test"
    Then I should see dropdown with "Test Ldap User"

    When I select "Test Ldap User" from dropdown
    And save team
    Then team should contain "Test Ldap User"
    And team should not contain "Test User"

  Scenario: Redirect to instance role
    Given I am in the "TeamName" team
    And instance with "MyInstanceRole" role belong to "TeamName"
    And I am on the "TeamName" team page
    And I click on "MyInstanceRole"
    Then I should be redirected to instance role "MyInstanceRole" page

  @javascript
  Scenario: Deactivate team
    Given the "TeamName" team
    And queues and topics are configured
    And I am on the "TeamName" team page
    When I deactivate current team
    And confirm it with "TeamName"

    When I am on the teams page
    Then I should not see "TeamName"

    When I click on "show only inactive teams"
    Then I should see "TeamName"
