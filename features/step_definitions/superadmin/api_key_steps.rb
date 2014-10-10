When(/^I enter all required data for "(.*?)" api key$/) do |name|
  fill_in 'Name', with: name
  permissions = Rails.application.routes.named_routes.routes.values.select { |node| node.name[/(?=api)(?!api_key)/] }.map(&:name)
  check(permissions.first)
end

Then(/^I should see the "(.*?)" key details$/) do |name|
  api_key = ApiKey.where(name: name).first
  expect(page).to have_text(name)
  expect(page).to have_text(api_key.key)
end

Given(/^"(.*?)" api key$/) do |name|
  FactoryGirl.create(:api_key, name: name)
end

When(/^I update api key with name "(.*?)"$/) do |name|
  fill_in 'Name', with: name
  permissions = Rails.application.routes.named_routes.routes.values.select { |node| node.name[/(?=api)(?!api_key)/] }.map(&:name)
  permissions.each do |permission|
    check(permission)
  end
end
