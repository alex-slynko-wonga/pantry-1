Feature: Managing Teams
  @chef-zero
  Scenario: Adding a new Team
    Given I am on the teams page
    When An agent creates a new team named "TeamName"
    Then I should be on team page
    And I should see "TeamName"
    And new chef environment "team-name" should be created

  Scenario: Updating existing team
    Given the "TeamName" team
    And I am on the teams page
    When I update team "TeamName" with name "NewName"
    And I click "Teams"
    Then I should see "NewName"

  @javascript
  Scenario: Adding an user to the team
    Given the "TeamName" team
    And a LDAP user "Test Ldap User"
    And I am on the teams page
    When I click on "Edit"
    And I search for "Test"
    Then I should see dropdown with "Test Ldap User"

    When I select "Test Ldap User" from dropdown
    And save team
    Then team should contain "Test Ldap User"

  @javascript
  Scenario: Removing an user from the team
    Given the "TeamName" team with "Test User" user
    And I am on the teams page
    When I click on "Edit"
    And click on remove cross
    And save team
    Then team should not contain "Test User"
    
  Scenario: Show Create a new jenkins server in the team page
    Given the "TeamName" team
    And I am on the teams page
    When I click "TeamName"
    Then I should see "Jenkins server"
    And I should see "Create a new jenkins server"
    
  Scenario: Show the existing jenkins server in the team page
    Given the "TeamName" team
    And the team has a Jenkins server
    And I am on the teams page
    When I click "TeamName"
    Then I should see "Jenkins server"
    And I should see the Jenkins server name
    When I click the server link
    And I should see the url of the Jenkins server
