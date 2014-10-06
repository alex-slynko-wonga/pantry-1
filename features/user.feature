Feature: Show User Info
  Scenario: Show EC2 instances in the user page
    Given I have an EC2 instance in the team
    When I am on the user page
    Then I should see a table with the instance