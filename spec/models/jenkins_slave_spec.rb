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
    let(:id) { 11 }

    before(:each) do
      jenkins_slave = instance_double('JenkinsSlave', id: id)
      allow(JenkinsSlave).to receive(:last).and_return(jenkins_slave)
    end

    it "creates the name using 'agent-' + padding and a counter" do
      expect(subject.ec2_instance).to be_valid
      expect(subject.ec2_instance.name).to eq("agent-00000012")
    end

    context "when the last id is less than 99999999" do
      let(:id) { 99999998 }

      it "creates a name of 15 characters when the counter less than 99999999" do
        expect(subject.ec2_instance).to be_valid
        expect(subject.ec2_instance.name.length).to eq(14)
      end
    end

    context "when the last id is more than 99999999" do
      let(:id) { 99999999 }

      it "is invalid for windows" do
        subject.ec2_instance.platform = "windows"
        expect(subject.ec2_instance).to be_invalid
        is_expected.to be_invalid
      end
    end
  end
end
