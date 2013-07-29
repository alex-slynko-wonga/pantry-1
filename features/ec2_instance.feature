Feature: EC2 Instance
  In order to have all resources available
  As a team member
  I want to manage my EC2 instances

  @javascript
  Scenario: Creating a new instance
    Given I am in the "teamname" team
    And I request an instance named "instanceName" on domain "example.com"
    Then an instance build should be started

    When I am on the teams page
    And I click on "teamname"
    Then I should see "instanceName"

    When I click on "instanceName"
    Then I should see "Booting"

    When an instance is created
    And I am still on instance page
    Then I should see "Ready"
