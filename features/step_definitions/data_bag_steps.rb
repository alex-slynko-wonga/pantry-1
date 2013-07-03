Given(/^the data bag "(.*?)" is stored on "(.*?)"$/) do |data_bag_name, path|
  Chef::DataBag.stub(:list).and_return({data_bag_name => path})
end
