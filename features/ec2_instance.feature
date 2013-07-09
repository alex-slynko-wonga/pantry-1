Feature: EC2 Instance
Scenario: Creating a new instance
	Given the "teamname" team
	And I request an instance named "instanceName"
	Then an instance should be created