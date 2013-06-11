Feature: Tracking and logging external agent deployment jobs

		We need Pantry to be able to track deployment jobs and keep a record of each job's log output.

Scenario: An agent registers a new job
	When an agent has posts all the required job details
	Then it should receive a response containing a uri to the job
	
Scenario: An agent updates an existing job status
	Given an agent has registered a job on Pantry with jobid of 1
	And the agent updates the status of the job to "started" 
	Then it should receive a response containing a uri to the job
	
Scenario: An agent adds a log entry to a job
	Given an agent has registered a job on Pantry with jobid of 1
	When the agent adds a new log entry
	Then it should receive a response containing a uri to the job log