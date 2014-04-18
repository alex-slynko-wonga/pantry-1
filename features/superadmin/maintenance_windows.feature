Feature: As a superadmin
  To prevent panic
  I would like to notify users about maintenance

  Scenario: Plan maintenance
    Given I am a superadmin
    When I start maintenance "My maintenance" because of "Site not available"
    Then site should be in maintenance mode
    When I finish maintenance "My maintenance"
    Then site should not be in maintenance mode
