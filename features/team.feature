Feature: Managing Teams
  Scenario: Adding a new Team
    Given I am on the teams page
    And queues and topics are configured
    When An agent creates a new team named "TeamName"
    Then I should be on team page
    And I should see "TeamName"
    And the team page has the current user
    And I should see a flash message with "Team created successfully"
    And a new CI chef environment should be requested

  Scenario: Updating existing team
    Given I am in the "TeamName" team with "Test User" user
    And I am on the teams page
    When I update team "TeamName" with name "NewName"
    And I should see a flash message with "Team updated successfully"
    And I click "Teams"
    Then I should see "NewName"

  Scenario: Updating existing team when the user is not in it
    Given the "TeamName" team
    And I am on the "TeamName" team page
    Then I should not see "Edit this team"

  @javascript
  Scenario: Adding an user to the team
    Given I am in the "TeamName" team with "Test User" user
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
    Given I am in the "TeamName" team with "Test User" user
    And I am on the teams page
    When I click on "Edit"
    And click on remove cross
    And save team
    Then team should not contain "Test User"

  Scenario: Show Create a new jenkins server in the team page
    Given I am in the "TeamName" team
    And I am on the teams page
    When I click "TeamName"
    Then I should see "Jenkins server"
    And I should see "Create a new jenkins server"

  Scenario: Show the existing jenkins server in the team page
    Given I am in the "TeamName" team
    And the team has a Jenkins server
    And I am on the teams page
    When I click "TeamName"
    Then I should see "Jenkins server"
    And I should see the Jenkins server name
    And I should see the url of the Jenkins server

  Scenario: Show EC2 instances in the team page
    Given I have an EC2 instance in the team
    When I am on the team page
    Then I should see the a table with the instance

