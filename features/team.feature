Feature: Managing Teams
  Scenario: Adding a new Team
    Given I am on the teams page
    When An agent creates a new team named "TeamName"
    Then I should be on team page
    And I should see "TeamName"

  Scenario: Updating existing team
    Given there exists a team named "TeamName"
    And I am on the teams page
    When I update team "TeamName" with name "NewName"
    And I click "Teams"
    Then I should see "NewName"

  @javascript
  Scenario: Adding user a to team
    Given the "TeamName" team
    And a LDAP user "Test Ldap User"
    And I am on the teams page
    When I click on "Edit"
    And I search for "Test"
    Then I should see dropdown with "Test Ldap User"

    When I select "Test Ldap User" from dropdown
    And save team
    Then team should contain "Test Ldap User"

