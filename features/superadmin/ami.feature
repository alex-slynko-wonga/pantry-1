Feature: Manage AMIs
  As superadmin
  I want to manage AMIs

  Background:
    Given I am a superadmin


  @javascript
  Scenario: Create a new AMI
    Given I am on the AMIs page
    And AWS has information about machines
    When I click 'New AMI'
    And I enter a valid ami ID
    Then I should see the AMI details on the right

    When I save the AMI as hidden
    Then I should see the hidden AMI in the AMIs listing

  @javascript
  Scenario: Change AMI name and make it not hidden
    Given I am editing an existing AMI
    And I change the name
    And I make it not hidden
    And I save it
    Then I should see the changed name
    And It should not be hidden

  @javascript
  Scenario: Delete an AMI
    Given I am editing an existing AMI
    When I click "Delete AMI"
    Then I should not see the AMI in the AMIs listing

