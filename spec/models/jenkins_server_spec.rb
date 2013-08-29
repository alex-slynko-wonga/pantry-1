# encoding: utf-8
require 'spec_helper'

describe JenkinsServer do
  describe "jenkins_slave" do
    it "avoids uninitialized constant JenkinsServer::JenkinsSlafe" do
      slave = FactoryGirl.build(:jenkins_slave)
      server = FactoryGirl.create(:jenkins_server)
      server.jenkins_slaves << slave
    end
  end

  describe "#instance_name" do

    it "gets instance_name from chef_environment" do
      team = Team.new(chef_environment: 'test')
      jenkins = JenkinsServer.new(team: team)
      e = Chef::Environment.new
      e.default_attributes = { 'jenkins' => { 'server' => { 'host' => 'pantry.test.example.com' } } }
      expect(Chef::Environment).to receive(:load).with('test').and_return(e)
      expect(jenkins.instance_name).to eq('pantry')
    end
  end
end
