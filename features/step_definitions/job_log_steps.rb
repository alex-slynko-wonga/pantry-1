Given(/^a job log exists on Pantry for JobID "(.*?)" with LogText "(.*?)"$/) do |job_id, log_text|
  page.driver.post "/job_logs", {job_id: job_id, log_text: log_text}
end

When(/^I am on job_logs page$/) do
  visit "/job_logs"
end


Given(/^an agent has registered a job log on Pantry for JobID "(.*?)" with LogText "(.*?)"$/) do |this_job_id, this_log_text|
  @job_log = FactoryGirl.create(:job_log)
  @job_log.job_id = this_job_id
  @job_log.log_text = this_log_text
  @job_log.save
end

When(/^I update the job log with LogText "(.*?)"$/) do |log_text|
  page.driver.put "/job_logs/#{@job_log.id}", {log_text: log_text}
end

When(/^I am on the job log's page$/) do
  visit "/job_logs/#{@job_log.id}"
end

