RSpec.describe InstanceRole do
  context '#update_volumes' do
    let(:role) { FactoryGirl.build_stubbed(:instance_role) }
    let(:volume) { role.ec2_volumes.first }
    let(:new_disk_size) { volume.size }
    let(:volumes) { [FactoryGirl.build(:ec2_volume_for_role, device_name: volume.device_name, size: new_disk_size)] }

    it 'updates snapshots' do
      snapshot = volume.snapshot
      role.update_volumes(volumes)
      expect(volume.snapshot).not_to eq snapshot
    end

    it "doesn't create new volume" do
      expect { role.update_volumes(volumes) }.not_to change(role.ec2_volumes, :size)
    end

    context 'if new size is bigger' do
      let(:new_disk_size) { volume.size + 50 }

      it 'updates size' do
        role.update_volumes(volumes)
        expect(volume.size).to eq new_disk_size
      end
    end

    context 'if new size is smaller' do
      let(:new_disk_size) { volume.size - 1 }

      it 'updates size' do
        role.update_volumes(volumes)
        expect(volume.size).not_to eq new_disk_size
      end
    end

    context 'when volumes with new device_name provided' do
      let(:volumes) { [FactoryGirl.build(:ec2_volume_for_role)] }

      it 'creates new volumes' do
        expect { role.update_volumes(volumes) }.to change(role.ec2_volumes, :size)
      end
    end
  end

  context '#instance_attributes' do
    subject { FactoryGirl.create(:instance_role) }
    let(:instance) { Ec2Instance.new(subject.instance_attributes) }

    it 'builds new instance' do
      run_list = 'role[new_test]'
      allow(subject).to receive(:full_run_list).and_return(run_list)
      expect(instance).to be_new_record
      expect(instance.run_list).to eq run_list
    end

    it 'duplicates volumes' do
      expect(instance.ec2_volumes.first).to be_new_record
      expect(instance.ec2_volumes.first).to be_valid
    end
  end

  context '#full_run_list' do
    subject { FactoryGirl.build(:instance_role, chef_role: chef_role, run_list: run_list).full_run_list }

    let(:chef_role) { 'test' }
    let(:run_list) { 'recipe[some]' }

    it 'joins role and run_list' do
      is_expected.to include("role[#{chef_role}]")
      is_expected.to include(run_list)
      is_expected.to include(',')
    end

    context 'when run_list is empty' do
      let(:run_list) { '' }

      it 'returns role' do
        is_expected.to eq 'role[test]'
      end
    end
  end
end
