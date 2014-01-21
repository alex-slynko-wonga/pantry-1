require 'spec_helper'

describe Wonga::Pantry::BootMessage do
  let(:instance) { FactoryGirl.build(:ec2_instance) }

  subject { described_class.new(instance) }

  describe "#boot_message" do
    it "splits run list and make it into array" do
      instance.run_list = "test\r\nsecond"
      expect(subject.boot_message[:run_list]).to eq(['test', 'second'])
    end

    it "gets ou from Wonga::Pantry::ActiveDirectoryOU" do
      allow(Wonga::Pantry::ActiveDirectoryOU).to receive(:new).and_return(instance_double('Wonga::Pantry::ActiveDirectoryOU', ou: 'test'))
      expect(subject.boot_message[:ou]).to eq('test')
    end
  end
end

