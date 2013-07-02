Feature: Make AWS API requests
Scenario: List EC2 instances
    Given I am on the EC2s page
    Then I should see "Groups"
Scenario: List AMI instances
	Given I am on the AMIs page
	Then I should see "Architecture"
Scenario: List Security Groups instances
	Given I am on the Security Groups Page
	Then I should see "Description"
Scenario: List VCP instances
	Given I am on the VCP Groups Page
	Then I should see "State"