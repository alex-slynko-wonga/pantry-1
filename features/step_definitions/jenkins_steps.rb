Given(/^I request jenkins server$/) do
  visit '/jenkins_servers/new'
  click_on 'Create server'
end

Given(/^I request a jenkins slave and server$/) do
  visit '/jenkins_servers/new'
  click_on 'Create server'
  click_on 'Create a new slave'
  click_on 'Create slave'
end