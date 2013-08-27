require 'spec_helper'

describe Ec2Instance do
  subject { FactoryGirl.build :ec2_instance }
  it { should be_valid }

  describe "boot_message" do
    it "splits run list and make it into array" do
      subject.run_list = "test\r\nsecond"
      expect(subject.boot_message[:run_list]).to eq(['test', 'second'])
    end

    it "gets ou from Wonga::Pantry::ActiveDirectoryOU" do
      Wonga::Pantry::ActiveDirectoryOU.stub_chain(:new, :ou).and_return('test')
      expect(subject.boot_message[:ou]).to eq('test')
    end

    it "adds default group" do
      expect(subject.boot_message[:security_group_ids]).to include('sg-00110010')
      subject.platform = 'windows'
      expect(subject.boot_message[:security_group_ids]).to include('sg-00110011')
    end
  end
end
