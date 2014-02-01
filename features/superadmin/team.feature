Feature: Managing Teams

  As superadmin
  To help other people
  I want to manage their teams

  @javascript
  Scenario: Managing team users
    Given the "TeamName" team with "Test User" user
    And a LDAP user "Test Ldap User"
    And I am a superadmin
    And I am on the "TeamName" team page
    When I click on "Edit"
    And I click on remove cross near "Test User"
    And I search for "Test"
    Then I should see dropdown with "Test Ldap User"

    When I select "Test Ldap User" from dropdown
    And save team
    Then team should contain "Test Ldap User"
    And team should not contain "Test User"
