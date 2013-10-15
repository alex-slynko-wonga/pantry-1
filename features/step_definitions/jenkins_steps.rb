Given(/^I request jenkins server$/) do
  visit '/jenkins_servers/new'
  click_on 'Create server'
end

Given(/^I have a jenkins server$/) do
  @jenkins_server = FactoryGirl.create(:jenkins_server, ec2_instance: FactoryGirl.create(:ec2_instance, :bootstrapped), team: @team)
end

Given(/^I have a jenkins slave$/) do
  @jenkins_slave = FactoryGirl.create(:jenkins_slave, ec2_instance: FactoryGirl.create(:ec2_instance, :bootstrapped), jenkins_server: @jenkins_server)
end

When(/^I click the server ID$/) do
  click_on @jenkins_server.id
end

When(/^I visit the Jenkins slave page$/) do
  visit "/jenkins_servers/#{@jenkins_server.id}/jenkins_slaves/#{@jenkins_slave.id}"
end

Then(/^I should see the server listing$/) do
  page.should have_content @jenkins_server.ec2_instance.name
end

Then(/^I should see the slaves listing$/) do
  page.should have_content @jenkins_slave.ec2_instance.instance_id
  page.should have_content @jenkins_slave.ec2_instance.name
  page.should have_content @jenkins_slave.ec2_instance.ami
  page.should have_content @jenkins_slave.ec2_instance.instance_id
  page.should have_content @jenkins_slave.ec2_instance.bootstrapped
  page.should have_content @jenkins_slave.ec2_instance.booted
  page.should have_content @jenkins_slave.ec2_instance.joined
end

When(/^I click destroy$/) do
  click_on "Destroy"
end

Then(/^I should be redirected to the Jenkins server page$/) do
  page.should have_content "Jenkins Slaves"
end

When(/^I click the jenkins slave$/) do
  click_on @jenkins_slave.id
end

Then(/^I should not be able to see "(.*?)"$/) do |text|
  page.should_not have_content text
end

When(/^I go into Jenkins slave page$/) do
  visit "/jenkins_servers/#{@jenkins_server.id}/jenkins_slaves/#{@jenkins_slave.id}"
end
