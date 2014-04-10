Then(/^I should receive email$/) do
  expect(ActionMailer::Base.deliveries.last.to).to include(User.first.email)
end
