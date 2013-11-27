Given(/^I request jenkins server$/) do
  visit '/jenkins_servers/new'
  click_on 'Create server'
end

Given(/^I have a jenkins server$/) do
  @jenkins_server = FactoryGirl.create(:jenkins_server, ec2_instance: FactoryGirl.create(:ec2_instance, :bootstrapped, team: @team), team: @team)
end

Given(/^I have a jenkins slave$/) do
  @jenkins_slave = FactoryGirl.create(:jenkins_slave, ec2_instance: FactoryGirl.create(:ec2_instance, :bootstrapped, team: @team), jenkins_server: @jenkins_server)
  @jenkins_slave.ec2_instance.update_attributes(state: "ready", terminated: true, booted: false, dns: false, bootstrapped: false, joined: false)
end

When(/^I click on the server ID$/) do
  click_on @jenkins_server.id
end

When(/^I visit the Jenkins slave page$/) do
  visit "/jenkins_servers/#{@jenkins_server.id}/jenkins_slaves/#{@jenkins_slave.id}"
end

Then(/^I should see the server listing$/) do
  expect(page).to have_content @jenkins_server.ec2_instance.name
end

Then(/^I should see the slaves listing$/) do
  @jenkins_slave ||= JenkinsSlave.last
  expect(page).to have_content @jenkins_slave.ec2_instance.instance_id
  expect(page).to have_content @jenkins_slave.ec2_instance.name
  expect(page).to have_content @jenkins_slave.ec2_instance.ami
  expect(page).to have_content @jenkins_slave.ec2_instance.instance_id
  expect(page).to have_content @jenkins_slave.ec2_instance.bootstrapped
  expect(page).to have_content @jenkins_slave.ec2_instance.booted
  expect(page).to have_content @jenkins_slave.ec2_instance.joined
end

Then(/^I should be redirected to the Jenkins server page$/) do
  expect(page).to have_content "Jenkins Slaves"
end

Then(/^I should be redirected to the Jenkins slave page$/) do
  @jenkins_slave ||= JenkinsSlave.last
  expect(page).to have_content @jenkins_slave.ec2_instance.name
end

Then(/^the slave should be starting$/) do
  @jenkins_slave ||= JenkinsSlave.last
  expect(@jenkins_slave.ec2_instance.state).to eq("starting")  
end

When(/^I click on the jenkins slave$/) do
  click_on @jenkins_slave.id
end

When(/^I go into Jenkins slave page$/) do
  visit "/jenkins_servers/#{@jenkins_server.id}/jenkins_slaves/#{@jenkins_slave.id}"
end

When(/^I request new slave$/) do
  page.click_on "Create a new slave"
  click_on "Create slave"
end

When(/^slave is deleted$/) do
  @jenkins_slave.update_attribute(:removed, true)
end

Given(/^the slave is shut down$/) do
  @jenkins_slave ||= JenkinsSlave.last
  @jenkins_slave.ec2_instance.update_attributes(state: "shutdown", booted: false)
end

Then(/^I should not see slave in listing$/) do
  expect(page).to_not have_content @jenkins_slave.ec2_instance.instance_id
  expect(page).to_not have_content @jenkins_slave.ec2_instance.name
  expect(page).to_not have_content @jenkins_slave.ec2_instance.ami
  expect(page).to_not have_content @jenkins_slave.ec2_instance.instance_id
  expect(page).to_not have_content @jenkins_slave.ec2_instance.bootstrapped
  expect(page).to_not have_content @jenkins_slave.ec2_instance.booted
  expect(page).to_not have_content @jenkins_slave.ec2_instance.joined
end
