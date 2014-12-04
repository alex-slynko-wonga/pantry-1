When(/^I enter all required data for "(.*?)" instance role$/) do |name|
  fill_in_default_role_values(name)
end

Then(/^I should see the "(.*?)" role details$/) do |name|
  instance_role = InstanceRole.where(name: name).first
  ami = Ami.find(instance_role.ami_id).name
  expect(page.text).to include(name)
  expect(page.text).to include('my-chef-role')
  expect(page.text).to include(ami)
  expect(page.text).to include(instance_role.instance_size)
  expect(page.text).to include('existed-iam')
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
  expect(page).to have_content 'Enabled: true'
end

def fill_in_default_role_values(name)
  fill_in 'Name', with: name
  find(:select, 'Ami').all(:option).last.select_option
  fill_in 'Chef role', with: 'my-chef-role'
  fill_in 'Iam instance profile', with: 'existed-iam'
  fill_in 'Run list', with: 'role[some]'
  find(:select, 'Instance size').all(:option).last.select_option
  fill_in 'Disk size', with: 80

  check("#{CONFIG['pantry']['security_groups_prefix']}APIServer-001122334455")
end
