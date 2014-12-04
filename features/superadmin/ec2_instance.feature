Feature: EC2 Instance
  In order to have all resources available
  As a superadmin
  I want to manage my EC2 instances

  Background:
    Given AWS has information about machines
    And queues and topics are configured
    And I am a superadmin

  @javascript
  Scenario: Creating a new instance with custom AMI
    Given I am in the "Pantry" team
    And "Pantry" team has an "INT" environment with name "TEST"
    And ami-123 "TestWindows" exists in AWS
    And I am on the ec2 instance new page
    When I enter all required data for ec2
    And I entered ami-123 in custom ami field
    Then I should see "TestWindows" after page is updated
    When I create machine
    Then I should see a flash message with "Ec2 Instance request succeeded."
    And an instance with ami-123 build should start

  @javascript
  Scenario: Creating a new instance with custom IAM
    Given I am in the "Pantry" team
    And "Pantry" team has an "INT" environment with name "TEST"
    And I am on the ec2 instance new page
    When I enter all required data for ec2
    And I entered "test_iam" in iam field
    When I create machine
    Then I should see a flash message with "Ec2 Instance request succeeded."
    And an instance with "test_iam" iam build should start

  @javascript
  Scenario: Fill bootstrap username for linux
    Given I am on the AMIs page
    And I am in the "test" team
    And ami-12111111 "TestWindows" exists in AWS
    And ami-12222222 "TestLinux" exists in AWS with platform "linux"
    When I click on "New AMI"
    And I enter "ami-12111111" in ami field
    Then I should not see "Bootstrap username"
    When I enter "ami-12222222" in ami field
    Then I should see "Bootstrap username"
    And I enter "Fedora" in bootstrap username field
    And I save the AMI

    And I am in the "Pantry" team
    And "Pantry" team has an "INT" environment with name "TEST"
    When I request an instance with "TestLinux" AMI
    Then I should see a flash message with "Ec2 Instance request succeeded."
    And the instance start using "Fedora" bootstrap username

  @javascript
  Scenario: Creating a new instance with instance role
    Given "MyInstanceRole" instance role
    And I am in the "TeamName" team
    And "TeamName" team has an "INT" environment with name "TEST"
    When I request an EC2 instance
    And I enter all required data for ec2
    And I choose "MyInstanceRole" instance role
    And I click on "Create"
    And I click on "MyInstanceRole"
    Then I should be redirected to instance role "MyInstanceRole" page

  @javascript
  Scenario: Creating a new instance with instance role, iam should be overridden
    Given "MyInstanceRole" instance role with "existed-iam" Iam profile
    And I am in the "TeamName" team
    And "TeamName" team has an "INT" environment with name "TEST"
    When I request an EC2 instance
    And I enter all required data for ec2
    And I entered "test_iam" in iam field
    And I choose "MyInstanceRole" instance role
    When I create machine
    Then I should see a flash message with "Ec2 Instance request succeeded."
    And an instance with "existed-iam" iam build should start

  @javascript
  Scenario: Creating a new instance with disabled role
    Given "MyInstanceRole" instance role is disabled
    And I am in the "TeamName" team
    And "TeamName" team has an "INT" environment with name "TEST"
    When I request an EC2 instance
    And I enter all required data for ec2
    And I choose "MyInstanceRole (disabled)" instance role
    And I click on "Create"
    Then I should see "Instance role: MyInstanceRole (disabled)"

  Scenario: Creating a new instance with hidden AMI
    Given hidden "Test" AMI
    And I am in the "Test" team
    Then "Test" AMI should be available for instance creation

