Then(/^I should see "(.*?)"$/) do |some_text|
  expect(page).to have_content(some_text)
end

Then(/^I should see "(.*?)" after page is updated$/) do |some_text|
  wait_until(5) do
    page.has_content? some_text
  end
  expect(page).to have_content(some_text)
end

Then(/^I should not see "(.*?)"$/) do |some_text|
  expect(page).to_not have_content(some_text)
end

When(/^I click (?:on )?"(.*?)"$/) do |text|
  click_on text
end

When(/^I create/) do
  click_on 'Create'
end

When(/^I destroy/) do
  click_on 'Destroy'
end

When(/^I cleanup/) do
  click_on 'Run machine cleanup'
end

When(/^I click on remove cross near "(.*?)"$/) do |value|
  find(:xpath, "//div/input[@value='#{value}']/../i[@class='icon-remove']").click
end

Then(/^I should see a flash message with "(.*?)"$/) do |arg1|
  expect(page).to have_selector '.alert-message', text: arg1
end

Then(/^I should see "([^"]*)" button/) do |name|
  expect(page).to have_button name
end

Then(/^I should not see "([^"]*)" button/) do |name|
  expect(page).not_to have_button name
end

When(/^I save/) do
  first(:xpath, "//input[@name='commit']").click
end

When(/^I choose "(.*?)" (\w+ ?\w*)$/) do |option_name, dropdown_name|
  find(:select, dropdown_name.humanize).find(:option, option_name).select_option
end

Then(/^I should not be able to choose "(.*?)" (\w+ ?\w*)$/) do |option_name, dropdown_name|
  expect(find(:select, dropdown_name.humanize).all(:option).collect(&:text)).to_not include(option_name)
end

Then(/^I should see my name near "(.*?)"$/) do |event|
  expect(find(:xpath, "//tr/td/a[text()='#{User.last.username}']/../../td[text()='#{event}']")).to be_present
end

When(/^I click on "(.*?)" icon$/) do |alt|
  find(:xpath, "//img[@alt = '#{alt}']/parent::a").click
end
