Given(/^((?:\d|\.|\w)+) EC2 instance(?: named "(.*?)")?(?: which is (.*?))?$/) do |size, name, status|
  ami = FactoryGirl.create(:ami).ami_id
  attrs = { ami: ami }
  attrs[:flavor] = size if size != 'an'
  attrs[:name] = name if name
  attrs[:state] = status.split(' ').join('_') if status
  @ec2_instance = FactoryGirl.create(:ec2_instance, :running, attrs)
end

Given(/^I have (?:an|((?:\d|\.|\w)+)) EC2 instance(?: with "(.*?)" name|) in the team$/) do |size, name|
  user = User.first
  @team = user.teams.first
  unless @team
    @team = FactoryGirl.create(:team)
    @team.users << user
  end

  attributes = { user: user, team: @team }
  attributes[:flavor] = size if size
  attributes[:name] = name if name
  @ec2_instance = FactoryGirl.create(:ec2_instance, :running, attributes)
end

Given(/^I have an EC2 instance in the team with environment "(.*?)"$/) do |environment|
  user = User.first
  @team = user.teams.first
  environment = Environment.where(name: environment).first
  @ec2_instance = FactoryGirl.create(:ec2_instance, :running, user: user, team: @team, environment: environment)
end
