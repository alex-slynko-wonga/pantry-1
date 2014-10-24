Feature: Manage InstanceRoles
  As superadmin
  I want to manage InstanceRoles
  And be able to turn them On and Off

  Background:
    Given AWS has information about machines
    And I am a superadmin

  Scenario: Managing instance roles
    Given I am on the InstanceRoles page
    When I click on "New Instance Role"
    And I enter all required data for "TestRole" instance role
    And I click on "Create Instance role"
    Then I should see the "TestRole" role details

  Scenario: Forbid to change AMI platform
    Given "TestRole" instance role with "windows" Ami platform
    And I am on the InstanceRoles page
    When I click on "TestRole"
    Then I choose "windows" ami
    But I should not be able to choose "linux" ami

  Scenario: Enabling an instance role
    Given "TestRole" instance role
    And I am on the InstanceRoles page
    When I click on "TestRole"
    And I enable the role
    And I check security_group_id
    And I click on "Update Instance role"
    Then I should see "TestRole"
    And I should see cell "true"

  Scenario: Deleting an instance role
    Given "TestRole" instance role
    And I am on the InstanceRoles page
    When I click on "TestRole"
    And I click on "Delete Instance Role"
    Then I should not see "TestRole"