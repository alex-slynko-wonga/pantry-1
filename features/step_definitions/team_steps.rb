When(/^An agent creates a new team named "(.*?)"$/) do |name|
  sqs_client = AWS::SQS.new.client
  resp = sqs_client.stub_for(:get_queue_url)
  resp[:queue_url] = "https://some_url.example.com"
  click_on 'New Team'
  fill_in('team_name', :with => name)
  fill_in('team_description', :with => "TeamDescription")
  click_button("Submit")
end

Then(/^the team page has the current user$/) do
  page.should have_content User.last.name
end

Given(/^I update team "(.*?)" with name "(.*?)"$/) do |oldname, newname|
  visit '/teams'
  click_on 'Edit'
  fill_in('team_name', :with => newname)
  click_button("Submit")
end

Given(/^(I am in )?the "(.*?)" team(?: with "(.*?)" user)?$/) do |include_logged_user, team_name, user_name|
  @team = FactoryGirl.create(:team, name: team_name)
  @team.users << User.first if include_logged_user
  user = FactoryGirl.create(:user, name: user_name, team: @team) if user_name
end

Given(/^I am not in the "(.*?)" team$/) do |team_name|
  @team = FactoryGirl.create(:team)  
  User.last.teams.delete(Team.where(name: team_name))
end

Given(/^I am on the "(.*?)" page$/) do |arg1|
  visit team_url @team
end

Given(/^a LDAP user "(.*?)"$/) do |name|
  LdapResource.stub_chain(:new, :filter_by_name, :all).and_return([{'samaccountname' => [name], 'email' => [name], 'displayname' => [name]}])
end

Given(/^I am a member of "(.*?)"$/) do |team_name|
  @team.users << User.first
end

When(/^I search for "(.*?)"$/) do |search_term|
  input = find('input[type="search"]')
  input.set(search_term)
end

Then(/^I should see dropdown with "(.*?)"$/) do |text|
  expect(page).to have_xpath("//a[contains(text(),'#{text}')]")
end

When(/^I select "(.*?)" from dropdown$/) do |text|
  page.find(:xpath, "//a[contains(text(),'#{text}')]").click
end

When(/^save team$/) do
  click_on 'Submit'
  page.has_no_button? 'Submit'
end

Then(/^team should (not )?contain "(.*?)"$/) do |not_contains, name|
  user = User.where(name: name).first
  if not_contains
    expect(user.teams).to_not include(Team.last)
  else
    expect(user.teams).to include(Team.last)
  end
end

Given(/^the team has a Jenkins server$/) do
  @team.should be_true
  @jenkins_server = FactoryGirl.create(:jenkins_server,
                                       team: @team,
                                       ec2_instance: FactoryGirl.create(:ec2_instance, bootstrapped: true)
  )
end

Then(/^I should see the Jenkins server name$/) do
  page.should have_content @jenkins_server.ec2_instance.name
end

Then(/^I click the server link$/) do
  click_on @jenkins_server.ec2_instance.name
end

Then(/^I should see the url of the Jenkins server$/) do
  page.should have_selector("a[href='http://#{@jenkins_server.ec2_instance.name}.#{@jenkins_server.ec2_instance.domain}']")
end

Given(/^I have at least one EC2 in the team$/) do
  @team = FactoryGirl.create(:team)
  user = User.first
  @team.users << user
  @ec2_instance = FactoryGirl.create(:ec2_instance, :running, user: user, team: @team)
end

When(/^I am on the team page$/) do
  visit team_url @team
end

Then(/^I should see the a table with the instance$/) do
  page.should have_content @ec2_instance.name
  page.should have_content @ec2_instance.human_status
  page.should have_selector "img[src$='/assets/linux_icon.png']"
end
