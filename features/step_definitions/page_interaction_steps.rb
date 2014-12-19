Then(/^I should see "(.*?)"$/) do |some_text|
  expect(page).to have_content(some_text)
end

Then(/^I should see "(.*?)" after page is updated$/) do |some_text|
  wait_until(5) do
    page.has_content? some_text
  end
  expect(page).to have_content(some_text)
end

Then(/^option "(.*?)" should be present near instance$/) do |some_text|
  visit current_path
  expect(find(:xpath, "//tr/td/a[text()='#{Ec2Instance.last.name}']/../../td/a[text()='#{some_text}']")).to be_present
end

Then(/^option "(.*?)" should be present near instances with environment "(.*?)"$/) do |some_text, environment_name|
  visit current_path
  environment_id = Environment.where(name: environment_name).first.id
  instances = Ec2Instance.where(environment_id: environment_id)
  instances.each do |instance|
    expect(find(:xpath, "//tr/td/a[text()='#{instance.name}']/../../td/a[text()='#{some_text}']")).to be_present
  end
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
  expect(page).to have_selector '.alert', text: arg1
end

Then(/^I should see "([^"]*)" button/) do |name|
  expect(page).to have_button name
end

Then(/^I should not see "([^"]*)" button/) do |name|
  expect(page).not_to have_button name
end

When(/^I save/) do
  first(:xpath, "//input[@name='commit']").click
  has_no_xpath?("//input[@name='commit']")
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

When(/^I wait (\d+) seconds?$/) do |seconds|
  sleep seconds.to_i
end

Then(/^I should see "(.*?)" status near "(.*?)" name(?: after (\d+) seconds|)$/) do |status, name, seconds|
  wait_until(seconds.to_i) do
    has_xpath?("//tr/td/a[text()='#{name}']/../../td[text()='#{status}']")
  end
end

When(/^I click on collapsible button for "(.*?)" machine$/) do |name|
  find(:xpath, "//tr/td/a[text()='#{name}']/../../../../../../../..//div[@class='accordion-toggle']").click
end

When(/^make screenshot with "(.*?)" name$/) do |name|
  page.driver.save_screenshot("#{name}.png")
end

Then(/^I should see dropdown with "(.*?)"$/) do |text|
  expect(page).to have_xpath("//a[contains(text(),'#{text}')]")
end

When(/^I select "(.*?)" from dropdown$/) do |text|
  page.find(:xpath, "//a[contains(text(),'#{text}')]").click
end
