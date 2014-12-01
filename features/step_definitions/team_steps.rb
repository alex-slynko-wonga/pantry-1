When(/^An agent creates a new team named "(.*?)" with product "(.*?)" and region "(.*?)"$/) do |name, product, region|
  click_on 'New Team'
  fill_in('team_name', with: name)
  fill_in('team_product', with: product)
  fill_in('team_region', with: region)
  fill_in('team_description', with: 'TeamDescription')
  click_button('Submit')
end

Then(/^the team page has my info$/) do
  expect(page).to have_content User.last.name
end

Then(/^team "(.*?)" should not be duplicated$/) do |team_name|
  expect(find(:select, Team).all(:option, team_name).count).to equal(1)
end

Given(/^the "(.*?)" team is inactive$/) do |name|
  team = Team.where(name: name).first || FactoryGirl.create(:team, name: name)
  team.update_attribute(:disabled, true)
end

Given(/^I update team "(.*?)" with name "(.*?)" and product "(.*?)" and region "(.*?)"$/) do |oldname, newname, product, region|
  visit '/teams'
  click_on oldname
  click_on 'Edit'
  fill_in('team_name', with: newname)
  fill_in('team_product', with: product)
  fill_in('team_region', with: region)
  click_button('Submit')
end

Given(/^(I am in )?the "(.*?)" team(?: with "(.*?)" user)?$/) do |include_logged_user, team_name, user_name|
  @team = FactoryGirl.create(:team, name: team_name)
  @team.users << User.first if include_logged_user
  FactoryGirl.create(:user, name: user_name, team: @team) if user_name
end

Given(/^a LDAP user "(.*?)"$/) do |name|
  allow(LdapResource).to receive_message_chain(:new, :filter_by_name, :all).and_return(
    [{ 'samaccountname' => [name], 'email' => [name], 'displayname' => [name] }])
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
  expect(page).to have_content @jenkins_server.ec2_instance.name
end

Then(/^I should see the url of the Jenkins server$/) do
  expect(page).to have_selector("a[href='http://#{@jenkins_server.ec2_instance.name}.#{@jenkins_server.ec2_instance.domain}']")
end

Then(/^I should see a table with the instance$/) do
  expect(page).to have_content @ec2_instance.name
  expect(page).to have_content @ec2_instance.human_status
  expect(page).to have_content @ec2_instance.environment.human_name
  expect(page).to have_selector "img[src$='/assets/linux_icon.png']"
end

Then(/^I should (not )?see a short table with the instance$/) do |not_contains|
  if not_contains
    expect(page).to_not have_content @ec2_instance.name
    expect(page).to_not have_content @ec2_instance.human_status
    expect(page).to_not have_selector "img[src$='/assets/linux_icon.png']"
  else
    expect(page).to have_content @ec2_instance.name
    expect(page).to have_content @ec2_instance.human_status
    expect(page).to have_selector "img[src$='/assets/linux_icon.png']"
  end
end

Given(/^"(.*?)" team has (?:an|a|(hidden)) (?:"(.*?)" )?environment (?:"(.*?)")?$/) do |team_name, is_hidden, environment_type, environment_name|
  @team = Team.where(name: team_name).first
  if is_hidden
    FactoryGirl.create(:environment, environment_type: environment_type, team: @team, name: environment_name, hidden: true)
  else
    FactoryGirl.create(:environment, environment_type: environment_type, team: @team, name: environment_name)
  end
end

Given(/^"(.*?)" team does not have (?:"(.*?)" )?environment$/) do |team_name, environment_type|
  @team = Team.where(name: team_name).first
  @ci_environment_count = @team.environments.count { |environment| environment.environment_type == environment_type }
  expect(@ci_environment_count).to eq(0)
end
