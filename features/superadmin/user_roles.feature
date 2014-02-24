Feature: Roles assigning
  In order to allow people do stuff
  As a superadmin
  I want to assign roles to users

  Scenario: Assign role from user page
    Given I am a superadmin
    And a "John Doe" developer
    When I proceed to "John Doe" user page
    And I click "Edit"
    And I set "Team Admin" role
    And I save record
    Then "John Doe" should be a team_admin
