require 'spec_helper'

describe JenkinsSlave do
  describe "team" do
    it "returns the team" do
      slave = FactoryGirl.create(:jenkins_slave)
      slave.team.should == slave.jenkins_server.team
    end
  end
  
  describe "set_ec2_instance_name" do
    subject {FactoryGirl.create(:jenkins_slave)}
    
    it "creates the name using 'agent-' + padding and a counter" do
      # JenkinsSlave.stub(:get_last).and_return(11)
      JenkinsSlave.stub_chain(:last, :try).with(:id).and_return(11)
      subject.ec2_instance.name.should == "agent-000000012"
    end
    
    it "creates a name of 15 characters when the counter returns 11" do
      JenkinsSlave.stub_chain(:last, :try).with(:id).and_return(1)
      subject.ec2_instance.name.length.should == 15
    end
    
    it "creates a name of 15 characters when the counter returns 99999999" do
      JenkinsSlave.stub_chain(:last, :try).with(:id).and_return(99999999)
      subject.ec2_instance.name.length.should == 15
    end
    
    it "creates a name of 15 characters when the counter returns 199999999" do
      JenkinsSlave.stub_chain(:last, :try).with(:id).and_return(199999999)
      expect { subject }.to raise_error
    end
  end
end
