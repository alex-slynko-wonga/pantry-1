require 'spec_helper'

describe JenkinsSlave do
  describe "team" do
    it "returns the team" do
      slave = FactoryGirl.create(:jenkins_slave)
      slave.team.should == slave.jenkins_server.team
    end
  end
end
