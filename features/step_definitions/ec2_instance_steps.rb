Given(/^I request an instance named "(.*?)"$/) do |name|
  visit "aws/ec2_instance/new"
end



Then(/^an instance should be created$/) do
  pending # express the regexp above with the code you wish you had
end