Given(/^I request jenkins server$/) do
  visit '/jenkins_servers/new'
  click_on 'Create server'
end

