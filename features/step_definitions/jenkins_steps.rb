Given(/^I request jenkins server$/) do
  Environment.where(team_id: @team.id).first.update_attributes(chef_environment: 'myenv')
  visit '/jenkins_servers/new'
  click_on 'Create server'
end

Given(/^I have a jenkins server$/) do
  @jenkins_server = FactoryGirl.create(:jenkins_server, :running, team: @team)
end

Given(/^I have a jenkins slave$/) do
  @jenkins_slave = FactoryGirl.create(:jenkins_slave, :running, jenkins_server: @jenkins_server)
end

When(/^I click on the server ID$/) do
  click_on @jenkins_server.id
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
  expect(page).to have_content @jenkins_slave.ec2_instance.human_status
end

Then(/^I should be redirected to the Jenkins server page$/) do
  expect(page).to have_content "Jenkins Slaves"
end

Then(/^the slave should be starting$/) do
  @jenkins_slave = JenkinsSlave.last
  expect(@jenkins_slave.ec2_instance.state).to eq("starting")
end

When(/^I click on the jenkins slave$/) do
  click_on @jenkins_slave.id
end

Given(/^the team has a Jenkins server$/) do
  @jenkins_server = FactoryGirl.create(:jenkins_server,
                                       :running,
                                       team: @team
  )
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
  @jenkins_slave.ec2_instance.update_attributes(state: "shutdown")
end

Then(/^I should not see slave in listing$/) do
  expect(page).to_not have_content @jenkins_slave.ec2_instance.instance_id
  expect(page).to_not have_content @jenkins_slave.ec2_instance.name
  expect(page).to_not have_content @jenkins_slave.ec2_instance.ami
end

When(/^the slave does not belong to my team$/) do
  @team = FactoryGirl.create(:team)
  slave = JenkinsSlave.last
  slave.ec2_instance.team = @team
  slave.save(validate: false)
end

