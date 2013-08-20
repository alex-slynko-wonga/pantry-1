require 'spec_helper'

describe JenkinsServer do
  describe "jenkins_slave" do
    it "avoids uninitialized constant JenkinsServer::JenkinsSlafe" do
      slave = FactoryGirl.build(:jenkins_slave)
      server = FactoryGirl.create(:jenkins_server)
      server.jenkins_slaves << slave
    end
  end
end
