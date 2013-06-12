Feature: Tracking external agent job logs

    Pantry needs to track job logs and keep a record of each job log history.

    Scenario: An agent creates a new job log for a job
        Given a job log exists on Pantry for JobID "40" with LogText "Testing JobLog.create"
        When I am on job_logs page
        Then I should see "40"
		And I should see "Testing JobLog.create" 

    Scenario: An agent updates a job log with a message
        Given an agent has registered a job log on Pantry for JobID "41" with LogText "Initial Message"
        When I update the job log with LogText "Appended Message"
        And I am on the job log's page
        Then I should see "41"
        And I should see "Initial Message Appended Message"

    Scenario: A user lists all job logs
        Given a job log exists on Pantry for JobID "42" with LogText "Index Foo"
        Given a job log exists on Pantry for JobID "43" with LogText "Index Bar"
        When I am on job_logs page
        Then I should see "42"
		And I should see "Index Foo"
        And I should see "42"
		And I should see "Index Bar"