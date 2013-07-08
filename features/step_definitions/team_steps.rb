When(/^An agent creates a new team named "(.*?)"$/) do |name|
  click_on 'New Team'
  fill_in('team_name', :with => name)
  fill_in('team_description', :with => "TeamDescription")
  click_button("Submit")
end

Given(/^I update team "(.*?)" with name "(.*?)"$/) do |oldname, newname|
  visit '/teams'
  click_on 'Edit'
  fill_in('team_name', :with => newname)
  click_button("Submit")
end

Given(/^the "(.*?)" team(?: with "(.*?)" user)?$/) do |name, username|
  @team = FactoryGirl.create(:team, name: name)
  user = FactoryGirl.create(:user, username: username, team: @team) if username
end

Given(/^a LDAP user "(.*?)"$/) do |name|
  LdapResource.stub_chain(:new, :find_user_by_name).and_return([{'samaccountname' => [name], 'email' => [name], 'displayname' => [name]}])
end

When(/^I search for "(.*?)"$/) do |search_term|
  input = find('input[type="search"]')
  input.set(search_term)
end

Then(/^I should see dropdown with "(.*?)"$/) do |text|
  wait_until(5) { page.has_xpath?("//a[contains(text(),'#{text}')]") }
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
