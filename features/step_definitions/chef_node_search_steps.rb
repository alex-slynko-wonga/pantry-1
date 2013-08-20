Given(/^the node "(.*?)" with environment "(.*?)"$/) do |node_name, environment|
  build_chef_node(node_name, environment)
end

When(/^I search for node with environment "(.*?)"$/) do |query|
  visit('/chef_nodes/search')
  fill_in('Environment', with: query)
  fill_in('Role', with: '*')
  click_button('Search')
end
