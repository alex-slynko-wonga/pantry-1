

When(/^an agent posts all the required job details$/) do
  @response = page.driver.post "/jobs", {name: 'name', description: 'description', status: 'status'}
end

Then(/^it should receive a response containing a uri to the job$/) do
  @response.status.should == 201
  @response.body.should include("#{host}/jobs/#{Job.last.id}")
end

Given(/^an agent has registered a job on Pantry$/) do
  @job = FactoryGirl.create(:job)
end

When(/^the agent updates the status of the job to "(.*?)"$/) do |status|
  page.driver.put "/jobs/#{@job.id}", {status: status }
end

When(/^I am on the Jobs page$/) do
  visit "/jobs/#{@job.id}"
end

Then(/^I should see the status "(.*?)"$/) do |status|
  page.text.should include(status)
end