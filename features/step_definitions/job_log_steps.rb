When(/^an agent creates a job log for the job with LogText "(.*?)"$/) do |message|
  page.driver.post "/jobs/#{@job.id}/job_log", {job_id: @job.id, log_text: message}
end

When(/^I am on the job log page for the job$/) do
  visit "/jobs/#{@job.id}/job_log/#{@job_log.id}"
end

Given(/^an agent has registered a job log for the job with LogText "(.*?)"/) do |message|
  @job_log = FactoryGirl.build(:job_log, job_id: @job.id, log_text: message)
  @job_log.save
end

When(/^I update the job log for the job with LogText "(.*?)"$/) do |update_message|
  page.driver.put "/jobs/#{@job.id}/job_log/#{@job_log.id}", {log_text: update_message}
end

Then(/^I should see the job id$/) do
  page.text.should include(@job.id.to_s)
end