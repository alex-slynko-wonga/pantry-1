When(/^I enter all required data for "(.*?)" instance role$/) do |name|
  fill_in_default_role_values(name)
end

Then(/^I should see the "(.*?)" role details$/) do |name|
  expect(page).to have_text(name)
  instance_role = InstanceRole.where(name: name).first
  expect(page).to have_text('my-chef-role')
  expect(page).to have_text(instance_role.ami.name)
  expect(page).to have_text(instance_role.instance_size)
  expect(page).to have_text('existed-iam')
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
  fill_in 'Name', with: name, match: :first
  find(:select, 'Ami').all(:option).last.select_option
  fill_in 'Chef role', with: 'my-chef-role'
  fill_in 'Iam instance profile', with: 'existed-iam'
  fill_in 'Run list', with: 'role[some]'
  find(:select, 'Instance size').all(:option).last.select_option
  first(:xpath, '//input[contains(@id, "instance_role_ec2_volumes") and contains(@id, "size")]').set(100)
  first(:xpath, '//input[contains(@id, "instance_role_ec2_volumes") and contains(@id, "device_name")]').set('/dev/sda1')

  check("#{CONFIG['pantry']['security_groups_prefix']}APIServer-001122334455")
end
