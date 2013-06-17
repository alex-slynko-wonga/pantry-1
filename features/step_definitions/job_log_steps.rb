When(/^an agent creates a job log for the job with LogText "(.*?)"$/) do |message|
  @job_log_create_response = page.driver.post "/jobs/#{@job.id}/job_logs", {job_id: @job.id, log_text: message}
  @job_log_create_response.status.should == 201
  @job_log ||= JobLog.last
  @job_log_create_response.body.should include("#{host}/jobs/#{@job_log.job_id}/job_logs/#{@job_log.id}")
end

When(/^I am on the job logs page for the job$/) do
  visit "/jobs/#{@job.id}/job_logs"
end

When(/^I am on the job log page for the job$/) do
  @job_log ||= JobLog.last
  visit "/jobs/#{@job_log.job_id}/job_logs/#{@job_log.id}"
end

Given(/^an agent has registered a job log for the job with LogText "(.*?)"/) do |message|
  @job_log = FactoryGirl.create(:job_log, job: @job, log_text: message)
end

When(/^I update the job log for the job with LogText "(.*?)"$/) do |update_message|
  @job_log ||= JobLog.last
  @job_log_update_response = page.driver.put "/jobs/#{@job_log.job_id}/job_logs/#{@job_log.id}", {log_text: update_message}
  @job_log_update_response.status.should == 200
end

Then(/^I should see the job id$/) do
  page.text.should include(@job.id.to_s)
end