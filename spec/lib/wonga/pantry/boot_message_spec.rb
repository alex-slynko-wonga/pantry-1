require 'spec_helper'

describe Wonga::Pantry::BootMessage do
  let(:instance) { FactoryGirl.build_stubbed(:ec2_instance) }

  subject { described_class.new(instance) }

  describe "#boot_message" do
    it "splits run list and make it into array" do
      instance.run_list = "test\r\nsecond,third"
      expect(subject.boot_message[:run_list]).to eq(['test', 'second', 'third'])
    end

    it "gets ou from Wonga::Pantry::ActiveDirectoryOU" do
      allow(Wonga::Pantry::ActiveDirectoryOU).to receive(:new).and_return(instance_double('Wonga::Pantry::ActiveDirectoryOU', ou: 'test'))
      expect(subject.boot_message[:ou]).to eq('test')
    end

    context "when instance is not saved" do
      let(:instance) { Ec2Instance.new }
      it "raise exception" do
        expect { subject.boot_message }.to raise_exception
      end
    end
  end
end

