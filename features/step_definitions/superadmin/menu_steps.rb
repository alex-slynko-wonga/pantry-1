When(/^I am in the home page$/) do
  visit '/'
end

Then(/^I should see the admin dropdown menu$/) do
  expect(find('li.dropdown').find('a.dropdown-toggle').text).to eq "Admin"
  expect(find(:xpath, "//ul[contains(@class, 'dropdown-menu')]/li/a[text()='Maintenance']")).to be_present
  expect(find(:xpath, "//ul[contains(@class, 'dropdown-menu')]/li/a[text()='AMIs']")).to be_present
end
