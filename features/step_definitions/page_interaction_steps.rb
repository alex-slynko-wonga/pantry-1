Then(/^I should see "(.*?)"$/) do |some_text|
  wait_until(5) { page.text.include? some_text }
end

When(/^I click (?:on )?"(.*?)"$/) do |text|
  click_on text
end

When(/^click on remove cross$/) do
  first('i.icon-remove').click
  find('i.icon-remove').click
end
