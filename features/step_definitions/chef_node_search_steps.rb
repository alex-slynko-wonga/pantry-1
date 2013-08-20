When(/^I search for node with environment "(.*?)"$/) do |query|
  visit('/chef_nodes/search')
  fill_in('Environment', with: query)
  fill_in('Role', with: '*')
  click_button('Search')
end
