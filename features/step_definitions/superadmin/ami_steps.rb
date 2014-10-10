When(/^I enter "(.*?)" in ami field$/) do |id|
  fill_in 'AMI id', with: id
end

Then(/^I should see the AMI details on the right$/) do
  wait_until(5) do
    page.has_content? 'General information'
  end
  expect(page).to have_text 'General information'
  expect(page).to have_text 'Devices'
  expect(page).to have_text 'Tags'
end

When(/^I hide the "(.*?)" AMI$/) do |name|
  visit edit_admin_ami_path(Ami.where(name: name).first)
  check 'Hidden'
  first(:xpath, "//input[@name='commit']").click
end

When(/^I change the "(.*?)" AMI name to "(.*?)"$/) do |old_name, new_name|
  visit edit_admin_ami_path(Ami.where(name: old_name).first)
  fill_in 'Name', with: new_name
  first(:xpath, "//input[@name='commit']").click
end

When(/^I delete "(.*?)" AMI$/) do |name|
  visit edit_admin_ami_path(Ami.where(name: name).first)
  click_button 'Delete AMI'
end

When(/^I update "(.*?)" AMI$/) do |name|
  visit edit_admin_ami_path(Ami.where(name: name).first)
end

When(/^I enter "(.*?)" in bootstrap username field$/) do |value|
  fill_in 'Bootstrap username', with: value
end
