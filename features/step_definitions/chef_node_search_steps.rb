Given(/^the node "(.*?)" with environment "(.*?)"$/) do |arg1, arg2|
  pending # express the regexp above with the code you wish you had
end

When(/^I search for node with environment "(.*?)"$/) do |query|
  visit('/chef_nodes/search')
  fill_in('Environment', :with => query)
  click_button('Search')
end