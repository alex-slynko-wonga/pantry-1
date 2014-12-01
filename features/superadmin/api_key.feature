Feature: Manage InstanceRoles
  As superadmin
  I want to manage Api Keys

  Background:
    Given I am a superadmin

  Scenario: Creating a new api key
    Given I am on the ApiKeys page
    When I click on "New Api Key"
    And I enter all required data for "TestApiKey" api key
    And I click on "Create Api key"
    Then I should see the "TestApiKey" key details

  Scenario: Updating an api key
    Given "TestApiKey" api key
    And I am on the ApiKeys page
    When I click on "TestApiKey"
    And I update api key with name "NewTestApiKey"
    And I click on "Update Api key"
    Then I should see "NewTestApiKey"

  Scenario: Deleting an api key
    Given "TestApiKey" api key
    And I am on the ApiKeys page
    When I click on "TestApiKey"
    And I click on "Delete Api Key"
    Then I should not see "TestApiKey"