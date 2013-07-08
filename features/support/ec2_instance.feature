Feature: EC2 instance
Scenario: Creating an EC2 instance
	Given the "myteam" team
	And I request an instance named "Instance"
	Then an instance should be created
