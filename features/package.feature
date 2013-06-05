Feature: Manage Package Data
Scenario: Add a new package
    Given a build agent has provided a package of name "Test package" with version "0.0.1" placed on url "http://pantry.aws"
    When I am on packages page
    Then I should see "Test package"
    And I should see "0.0.1"
    And I should see "http://pantry.aws"