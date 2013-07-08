When(/^An agent creates a new team named "(.*?)"$/) do |name|
  click_on 'New Team'
  fill_in('team_name', :with => name)
  fill_in('team_description', :with => "TeamDescription")
  click_button("Submit")
end

Given(/^there exists a team named "(.*?)"$/) do |tname|
  @team = FactoryGirl.create(:team)
end

Given(/^I update team "(.*?)" with name "(.*?)"$/) do |oldname, newname|
  visit '/teams'
  click_on 'Edit'
  fill_in('team_name', :with => newname)
  click_button("Submit")
end

Given(/^the "(.*?)" team$/) do |name|
  FactoryGirl.create(:team, name: name)
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

Then(/^team should contain "(.*?)"$/) do |name|
  user = User.where(name: name).first
  expect(user.teams).to include(Team.last)
end
