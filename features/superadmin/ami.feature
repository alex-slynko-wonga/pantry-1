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

  @javascript
  Scenario: Update an AMI with different platform should fail
    Given "Test" AMI with platform "windows"
    And I am in the "test" team
    When I update "Test" AMI
    And ami-12121212 "LinuxMachine" exists in AWS with platform "linux"
    And I enter "ami-12121212" in ami field
    Then I should see "AMI can't be updated with a different platform"

    When I click on "Update"
    Then I should see "AMI update failed"

  @javascript
  Scenario: Update an AMI with the same platform should pass
    Given "Test" AMI with platform "linux"
    And I am in the "test" team
    When I update "Test" AMI
    And ami-122112211 "WindowsMachine" exists in AWS with platform "linux"
    And I enter "ami-122112211" in ami field
    Then I should not see "AMI can't be updated with a different platform"

    When I click on "Update"
    And I should see "AMI updated successfully"

