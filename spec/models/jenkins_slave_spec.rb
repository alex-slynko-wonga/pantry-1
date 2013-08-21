require 'spec_helper'

describe JenkinsSlave do
  describe "team" do
    it "returns the team" do
      slave = FactoryGirl.create(:jenkins_slave)
      slave.team.should == slave.jenkins_server.team
    end
  end
  
  describe "isntances" do
    it "returns the instances" do
      slave = FactoryGirl.create(:jenkins_slave)
      JenkinsSlave.ec2_instances([slave.ec2_instance]).first.should == slave.ec2_instance
    end
  end
end
