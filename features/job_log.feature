Feature: Tracking external agent deployment job logs

		We need Pantry to be able to track deployment job logs and keep a record of each job log history.
		
Scenario: An agent adds a log entry to a job
	Given an agent has registered a job on Pantry
	When the agent adds a new log entry
	Then I should be able to view the log entry for the job