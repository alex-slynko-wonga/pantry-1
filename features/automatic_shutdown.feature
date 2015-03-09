Feature: Automatic shutdown

  As a responsible developer
  I would like
  To shutdown my instances when I don't use them

  Scenario: Automatic shutdown
    Given I have an EC2 instance with "everyday" name in the team
    And an EC2 instance named "weekend"
    When it is 5.55 pm on Friday
    And schedule for "everyday" is to shutdown at 8 pm every day
    And schedule for "weekend" is to shutdown at 7 pm before weekend
    And schedule for "everyday" is to start at 8 am every day
    And schedule for "weekend" is to start at 7 am after weekend
    Then no instances are expected to shutdown
    When it is 6.55 pm on Friday
    Then "weekend" instance is expected to shutdown
    When "weekend" instance is shutdown automatically
    And it is 7.55 pm on Friday
    Then "everyday" instance is expected to shutdown
    When "everyday" instance is shutdown automatically
    And it is 7.05 am on Sunday
    Then no instances are expected to start
    When it is 7.05 am on Monday
    Then "weekend" instance is expected to start
    When it is 8.05 am on Monday
    Then "everyday" and "weekend" instance are expected to start
    When "weekend" instance is started automatically
    And "everyday" instance is started automatically
    Then no instances are expected to start
    And it is 7.55 pm on Monday
    Then "everyday" instance is expected to shutdown
    When "everyday" instance is shutdown manually
    And it is 8.05 am on Monday
    Then no instances are expected to start
