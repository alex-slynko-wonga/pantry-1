When(/^I request team environment$/) do
  Environment.delete_all
  sqs_client = AWS::SQS.new.client
  fill_in 'environment_description', with: 'Environment for ...'
end

When(/^I select "(.*?)" as environment type$/) do |env_type|
  select(env_type, from: 'environment_environment_type')
end

When(/^name it as "(.*?)"$/) do |name|
  fill_in 'environment_name', with: name
end

When(/^I save it$/) do
  sqs_client = AWS::SQS.new.client
  @sqs = instance_double('Wonga::Pantry::SQSSender')
  allow(Wonga::Pantry::SQSSender).to receive(:new).and_return(@sqs)
  @sqs.stub(:send_message)

  click_button 'Create Environment'
  Environment.last.update_attributes(chef_environment: 'ours') # simulate that the daemon updates the chef_environment
end


When(/^the environment is created$/) do
  expect( @environment_counter + 1 ).to eq(Environment.count)
end

When(/^I request new ec2 instance$/) do
  click_link 'Launch New Instance'
end

Then(/^I should be able to choose "(.*?)"  from list of environemnts$/) do |env_type|
  select(env_type, from: 'Environment')
end
