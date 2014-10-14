Given(/^"(.*?)" instance role$/) do |name|
  FactoryGirl.create(:instance_role, name: name)
end

When(/^I enter all required data for "(.*?)" instance role$/) do |name|
  fill_in_default_role_values(name)
end

Then(/^I should see the "(.*?)" role details$/) do |name|
  expect(page.text).to include(name)
  expect(page.text).to include("my-chef-role")
  expect(page.text).to include("t1.micro")
end

When(/^I enable the role$/) do
  check('Enabled')
end

Then(/^I should see cell "(.*?)"$/) do |field|
  cells = page.all('table.table td').map(&:text)
  expect(cells).to include(field)
end

def fill_in_default_role_values(name)
  fill_in 'Name', with: name
  find(:select, 'Ami').all(:option).last.select_option
  fill_in 'Chef role', with: 'my-chef-role'
  fill_in 'Run list', with: 'role[some]'
  fill_in 'Instance size', with: 't1.micro'
  fill_in 'Disk size', with: 80

  check("#{CONFIG['pantry']['security_groups_prefix']}APIServer-001122334455")
end