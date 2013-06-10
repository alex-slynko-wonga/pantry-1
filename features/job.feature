Feature: Manage Job Data

Scenario: Add a new Job to Pantry
	Given an agent has provided a Job of name "Test Job" with Description "Test Description", with Status "Pending"
	And it is "2013-06-10 10:00:00 UTC" now
	When I am on the Job page
	Then I should see "1"
	And I should see "Test Job"
	And I should see "Test Description"
	And I should see "2013-06-10 10:00:00 UTC"
	And I should see "Pending"
	
Scenario: Update a Job on Pantry
	Given an agent has provided a Job of name "Test Job"
	And it is "2013-06-10 10:00:00 UTC" now
	When I am on the Job page
	Then I should see "1"
	And I should see "Test Job"
	And I should see "2013-06-10 10:00:00 UTC"
	
