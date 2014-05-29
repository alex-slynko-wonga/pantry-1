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

When(/^I click on remove cross near "(.*?)"$/) do |value|
  find(:xpath, "//div/input[@value='#{value}']/../i[@class='icon-remove']").click
end

Then(/^I should see a flash message with "(.*?)"$/) do |arg1|
  page.should have_selector '.alert-message', text: arg1
end

Then(/^I should see "([^"]*)" button/) do |name|
  should have_button name
end

Then(/^I should not see "([^"]*)" button/) do |name|
  should_not have_button name
end

When(/^I save/) do
  first(:xpath, "//input[@name='commit']").click
end
