Feature: Tracking external agent deployment jobs

		We need Pantry to be able to track deployment jobs and keep a record of each job's history.

Scenario: An agent registers a new job
	When an agent posts all the required job details
	Then it should receive a response containing a uri to the job
	
Scenario: An agent updates an existing job status
	Given an agent has registered a job on Pantry
	When the agent updates the status of the job to "started" 
	And I am on the Jobs page 
	Then I should see the status "started"