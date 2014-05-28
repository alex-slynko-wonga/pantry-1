Given(/^I am on the AMIs page$/) do
  visit admin_amis_path
  expect(page).to have_content 'AMIs'
end

When(/^I click 'New AMI'$/) do
  click_on "New AMI"
end

When(/^I enter a valid ami ID$/) do
  fill_in 'ami_id', with: 'i-121111'
end

Then(/^I should see the AMI details on the right$/) do
  begin
    wait_until(5) do
      page.has_content? "General information"
    end
  rescue Timeout::Error
    expect(page.text).to include "General information"
  end
  expect(page.text).to include "Devices"
  expect(page.text).to include "Tags"
end

When(/^I save the AMI as hidden$/) do
  check "hidden"
  fill_in "Name", with: "test-ami"
  click_button "Submit"
end

Then(/^I should see the hidden AMI in the AMIs listing$/) do
  expect(page.find(".table")).to be_present
  expect(page.text).to include "i-121111"
  expect(page.text).to include "true"
end

When(/^I change the name$/) do
  fill_in "Name", with: "new-name"
end

When(/^I make it not hidden$/) do
  uncheck "hidden"
end

When(/^I save it$/) do
  click_button "Submit"
end

Then(/^I should see the changed name$/) do
  begin
    wait_until(5) do
      page.has_content? "new-name"
    end
  rescue Timeout::Error
    expect(page).to have_content("new-name")
  end
end

Then(/^It should not be hidden$/) do
  expect(page.text).not_to include "true"
end

Given(/^I am editing an existing AMI$/) do
  @ami = FactoryGirl.create(:ami, hidden: true)
  visit edit_admin_ami_path(@ami)
end

Then(/^I should not see the AMI in the AMIs listing$/) do
  expect(page.text).not_to include "i-121111"
end
