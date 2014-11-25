When(/^I deactivate current team$/) do
  click_on 'Deactivate'
end

When(/^confirm it(?: with "(.*?)")?$/) do |value|
  fill_in 'confirm', with: value if value
  click_on 'Confirm'
  wait_until do
    has_no_button?('Confirm')
  end
end
