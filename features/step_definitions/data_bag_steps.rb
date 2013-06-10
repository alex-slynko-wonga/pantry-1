Given(/^the data bag "(.*?)" is stored on "(.*?)"$/) do |data_bag_name, path|
  Chef::DataBag.stub(:list).and_return({data_bag_name => path})
end

When(/^I am on data bags page$/) do
  visit data_bags_path
end
