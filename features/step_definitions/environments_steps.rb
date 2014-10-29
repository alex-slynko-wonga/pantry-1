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
  put "/api/teams/#{environment.team_id}/chef_environments/#{environment.id}", environment_name: environment.name,
    chef_environment: environment.name, format: :json
end

When(/^I request new ec2 instance$/) do
  click_link 'Launch New Instance'
end

Then(/^I should be able to choose "(.*?)" from list of environments$/) do |env_type|
  select(env_type, from: 'Environment')
end

Given(/^"(.*?)" team has an (?:"(.*?)" )?environment with name "(.*?)"$/) do |team_name, environment_type, environment_name|
  @team = Team.where(name: team_name).first
  FactoryGirl.create(:environment, environment_type: environment_type, team: @team, name: environment_name)
end

Then(/^I should see environment details/) do
  expect(page).to have_content @environment.name
  expect(page).to have_content @environment.environment_type
  expect(page).to have_content @environment.chef_environment
  expect(page).to have_content @environment.team.name
  expect(page).to have_content @environment.human_name
  expect(page).to have_content @environment.description
end

When(/^I click on environment human name$/) do
  click_on @environment.human_name
end

Then(/^I should see all environment human names except CI$/) do
  @team.environments.each do |environment|
    if environment.environment_type != 'CI'
      expect(page).to have_content environment.human_name
    end
  end
end

Then(/^I can( not)? create a new CI environment$/) do |not_contains|
  if not_contains
    expect(page).to_not have_content 'Create a new CI environment'
  else
    expect(page).to have_content 'Create a new CI environment'
  end
end

When(/^I update environment with name "(.*?)" and description "(.*?)"$/) do |new_name, new_description|
  click_on 'Edit this environment'
  fill_in('Name', with: new_name)
  fill_in('Description', with: new_description)
  click_button('Update Environment')
end
