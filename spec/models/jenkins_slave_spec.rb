require 'spec_helper'

describe JenkinsSlave do
  subject { FactoryGirl.build(:jenkins_slave) }

  it { should be_valid }

  describe "team" do
    it "returns the team" do
      expect(subject.team).to eq(subject.jenkins_server.team)
      expect(subject.team).to eq(subject.ec2_instance.team)
    end

    it "is validated to be same for server and this instance" do
      subject.jenkins_server.team = FactoryGirl.build(:team)
      expect(subject).to be_invalid
    end
  end

  describe "set_ec2_instance_name" do
    it "creates the name using 'agent-' + padding and a counter" do
      JenkinsSlave.stub_chain(:last, :try).with(:id).and_return(11)
      subject.valid?
      subject.ec2_instance.name.should == "agent-000000012"
    end

    it "creates a name of 15 characters when the counter returns 11" do
      JenkinsSlave.stub_chain(:last, :try).with(:id).and_return(1)
      subject.valid?
      subject.ec2_instance.name.length.should == 15
    end

    it "creates a name of 15 characters when the counter returns 99999999" do
      JenkinsSlave.stub_chain(:last, :try).with(:id).and_return(99999999)
      subject.valid?
      subject.ec2_instance.name.length.should == 15
    end

    it "creates a name of 15 characters when the counter returns 199999999" do
      JenkinsSlave.stub_chain(:last, :try).with(:id).and_return(199999999)
      expect(subject).to be_invalid
    end
  end
end
