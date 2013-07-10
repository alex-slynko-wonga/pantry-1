Given(/^I request an instance named "(.*?)"$/) do |name|
  visit "aws/ec2_instances/new"
  fill_in "ec2_instance_name", with: name
  click_on "Create"
end

Then(/^an instance should be created$/) do
  #pending # express the regexp above with the code you wish you had
end