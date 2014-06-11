Feature: Manage AMIs
  As superadmin
  I want to manage AMIs

  Background:
    Given I am a superadmin

  @javascript
  Scenario: Managing AMI
    Given I am on the AMIs page
    And I am in the "test" team
    And ami-12111111 "TestWindows" exists in AWS
    When I click on "New AMI"
    And I enter "ami-12111111" in ami field
    Then I should see the AMI details on the right

    When I save the AMI
    Then "TestWindows" AMI should be available for instance creation

    And I change the "TestWindows" AMI name to "Test"
    Then "Test" AMI should be available for instance creation

  Scenario: Hide an AMI
    Given "Test" AMI
    When I hide the "Test" AMI

    Given I am a developer
    And I am in the "test" team
    Then "Test" AMI should not be available for instance creation

  @javascript
  Scenario: Delete an AMI
    Given "Test" AMI
    And I am in the "test" team
    When I delete "Test" AMI
    Then "Test" AMI should not be available for instance creation

