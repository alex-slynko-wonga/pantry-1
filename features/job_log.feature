Feature: Tracking external agent job logs

    Pantry needs to track job logs and keep a record of each job log history.

    Scenario: An agent creates a new job log for a job
        Given an agent has registered a job on Pantry
        When an agent creates a job log for the job with LogText "Test Message"
        And I am on the job log page for the job
        Then I should see "Test Message"

    Scenario: An agent updates a job log with a message
        Given an agent has registered a job on Pantry
        And an agent has registered a job log for the job with LogText "Initial Message"
        When I update the job log for the job with LogText "Appended Message"
        And I am on the job log page for the job
        Then I should see the job id
        And I should see "Initial Message"
        And I should see "Appended Message"
