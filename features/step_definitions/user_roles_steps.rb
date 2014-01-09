Given(/^I am a manager$/) do
  config =  Marshal.load(Marshal.dump(CONFIG))
  config['billing_users'] ||= []
  config['billing_users'] << User.first.email
  stub_const('CONFIG', config)
  page.visit current_path
end

Given(/^I am a superadmin$/) do
  User.first.update_attribute(:role, 'superadmin')
  page.visit current_path
end

Given(/^a "(.*?)" (\w+_?\w*)$/) do |name, role|
  FactoryGirl.create(:user, name: name, role: role)
end

Then(/^"(.*?)" should be a (\w+_?\w*)$/) do |name, role|
  expect(User.where(name: name, role: role)).to exist
end

When(/^I set "(.*?)" role$/) do |role|
  select role.underscore.gsub(' ', '_'), from: 'Role'
end
