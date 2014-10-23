Given(/^"(.*?)" instance role$/) do |name|
  instance_role = FactoryGirl.create(:instance_role, name: name)
  stub_ami_info(instance_role.ami.ami_id)
end

Given(/^"(.*?)" instance role is disabled$/) do |name|
  instance_role = FactoryGirl.create(:instance_role, name: name, enabled: false)
  stub_ami_info(instance_role.ami.ami_id)
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

When(/^I check security_group_id/) do
  check("#{CONFIG['pantry']['security_groups_prefix']}APIServer-001122334455")
end

Then(/^I should see cell "(.*?)"$/) do |field|
  cells = page.all('table.table td').map(&:text)
  expect(cells).to include(field)
end

Then(/^I should be redirected to instance role "(.*?)" page$/) do |name|
  expect(page).to have_content "Instance role: #{name}"
  expect(page).to have_content "Enabled: true"
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