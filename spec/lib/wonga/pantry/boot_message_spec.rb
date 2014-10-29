require 'spec_helper'

RSpec.describe Wonga::Pantry::BootMessage do
  let(:instance) { FactoryGirl.build_stubbed(:ec2_instance) }

  describe '#boot_message' do
    let(:boot_message) { subject.boot_message(instance) }

    it 'splits run list and make it into array' do
      instance.run_list = "test\r\nsecond,third"
      expect(boot_message[:run_list]).to eq(%w(test second third))
    end

    it 'gets ou from Wonga::Pantry::ActiveDirectoryOU' do
      allow(Wonga::Pantry::ActiveDirectoryOU).to receive(:new).and_return(instance_double('Wonga::Pantry::ActiveDirectoryOU', ou: 'test'))
      expect(boot_message[:ou]).to eq('test')
    end

    context 'when instance is not saved' do
      let(:instance) { Ec2Instance.new }
      it 'raise exception' do
        expect { boot_message }.to raise_exception
      end
    end

    describe 'block_device_mappings' do
      it 'processes single drive'

      context 'for linux' do
        it 'processes additional drive'
      end

      context 'for windows' do
        it 'processes additional drive'
      end
    end
  end
end
