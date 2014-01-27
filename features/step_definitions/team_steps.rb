When(/^An agent creates a new team named "(.*?)"$/) do |name|
  @sqs = instance_double('Wonga::Pantry::SQSSender')
  allow(Wonga::Pantry::SQSSender).to receive(:new).and_return(@sqs)
  @sqs.stub(:send_message)

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

Given(/^a LDAP user "(.*?)"$/) do |name|
  LdapResource.stub_chain(:new, :filter_by_name, :all).and_return([{'samaccountname' => [name], 'email' => [name], 'displayname' => [name]}])
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

Then(/^I should see the Jenkins server name$/) do
  page.should have_content @jenkins_server.ec2_instance.name
end

Then(/^I click the server link$/) do
  first(:link, @jenkins_server.ec2_instance.name)
end

Then(/^I should see the url of the Jenkins server$/) do
  page.should have_selector("a[href='http://#{@jenkins_server.ec2_instance.name}.#{@jenkins_server.ec2_instance.domain}']")
end

When(/^I am on the team page$/) do
  visit team_url @team
end

Then(/^I should see the a table with the instance$/) do
  page.should have_content @ec2_instance.name
  page.should have_content @ec2_instance.human_status
  page.should have_selector "img[src$='/assets/linux_icon.png']"
end

Given(/^"(.*?)" team has an (?:"(.*?)" )?environment$/) do |team_name, environment_type|
  @team = Team.where(name: team_name).first
  FactoryGirl.create(:environment, environment_type: environment_type, team: @team)
end
