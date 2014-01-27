When(/^I request team environment$/) do
  fill_in 'environment_name', with: 'Env 1'
  fill_in 'environment_description', with: 'Environment for ...'
  fill_in 'environment_chef_environment', with: 'env1'
  select('INT', from: 'environment_environment_type')
  click_button 'Create Environment'
end

Then(/^I should see the team environment in team page$/) do
  expect(page).to have_content('Env 1')
  expect(page).to have_content('INT')
end
