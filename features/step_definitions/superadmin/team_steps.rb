When(/^I deactivate current team$/) do
  click_on 'Deactivate'
end

When(/^confirm it(?: with "(.*?)")?$/) do |value|
  fill_in 'confirm', with: value if value
  wait_until(8) do
    has_button?('Confirm')
  end
  click_on 'Confirm'
  wait_until(8) do
    has_no_button?('Confirm')
  end
end
