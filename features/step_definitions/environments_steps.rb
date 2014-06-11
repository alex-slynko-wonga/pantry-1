Then(/^a new (\w*) ?chef environment should be requested$/) do |env_type|
  expect(AWS::SQS.new.client).to have_received(:send_message) do |message|
    expect(JSON.parse(message[:message_body])['environment_type']).to eq(env_type) if env_type.present?
  end
end

When(/^I select "(.*?)" as environment type$/) do |env_type|
  select(env_type, from: 'Environment type')
end

When(/^name it as "(.*?)"$/) do |name|
  fill_in 'Name', with: name
end

When(/^environment is created$/) do
  environment = Environment.last
  header 'X-Auth-Token', CONFIG['pantry']['api_key']
  put "/api/teams/#{environment.team_id}/chef_environments/#{environment.id}",  environment_name: environment.name, chef_environment: environment.name, format: :json
end

When(/^I request new ec2 instance$/) do
  click_link 'Launch New Instance'
end

Then(/^I should be able to choose "(.*?)" from list of environments$/) do |env_type|
  select(env_type, from: 'Environment')
end
