# encoding: utf-8
require 'spec_helper'

describe JenkinsServer do
  describe "jenkins_slave" do
    it "avoids uninitialized constant JenkinsServer::JenkinsSlave" do
      slave = FactoryGirl.build(:jenkins_slave)
      server = FactoryGirl.create(:jenkins_server)
      server.jenkins_slaves << slave
    end
  end

  describe "#instance_name" do
    it "gets instance_name from team" do
      team = Team.new(chef_environment: 'test')
      jenkins = JenkinsServer.new(team: team)
      expect(jenkins.instance_name).to eq('test')
    end
  end
end
