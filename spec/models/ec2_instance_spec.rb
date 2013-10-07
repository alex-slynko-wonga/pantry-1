require 'spec_helper'

describe Ec2Instance do
  subject { FactoryGirl.build :ec2_instance }
  it { should be_valid }

  context "#is_running?" do
    it "is true when bootstrapped" do
      subject.bootstrapped = true
      expect(subject).to be_running
    end

    it "is false when terminated" do
      subject.bootstrapped = true
      subject.terminated = true
      expect(subject).to_not be_running
    end

    it "is false when is not bootstrapped" do
      subject.bootstrapped = false
      expect(subject).to_not be_running
    end
  end

  context "domain" do
    let(:domain) { 'example.com' }
    before(:each) do
      config = Marshal.load(Marshal.dump(CONFIG))
      config['pantry'] ||= {}
      config['pantry']['domain'] = domain
      stub_const('CONFIG', config)
    end

    it "should be invalid when is different from domain in config" do
      subject.domain = "wrong-domain.com"
      expect(subject).to be_invalid
      expect(subject).to have(1).error_on(:domain)
    end
  end

  context "#human_status" do
    let(:user) { User.new }

    it "is 'Booting' by default" do
      expect(subject.human_status).to eq('Booting')
    end

    { booted: 'Booted', joined: 'Joined to domain', bootstrapped: 'Bootstrapped', terminated: 'Terminated' }.each do |status, human_name|
      it "is '#{human_name}' when instance is #{status}" do
        subject[status] = true
        expect(subject.human_status).to eq(human_name)
      end
    end

    it "is 'Being terminated' if termination process is started" do
      subject.terminated_by = User.new
      expect(subject.human_status).to eq('Terminating')
    end

    it "is 'Ready' when joined and bootstrapped" do
      subject.joined = subject.bootstrapped = true
      expect(subject.human_status).to eq('Ready')
    end
  end

  it "should be invalid without run_list" do
    subject.run_list = nil
    expect(subject).to be_invalid
  end

  it "should be invalid with 6 security_group_ids" do
    subject.security_group_ids = ["sg-00000001","sg-00000002","sg-00000003","sg-00000004","sg-00000005","sg-00000006"]
    expect(subject).to be_invalid
  end

  it "raises a validation error if the user does not belogs to the current team" do
    user = FactoryGirl.create(:user)
    team = FactoryGirl.create(:team)
    instance = FactoryGirl.build(:ec2_instance, user: user, team: FactoryGirl.create(:team))
    team.should_not == instance.team
    expect {instance.save!}.to raise_error(ActiveRecord::RecordInvalid)
  end

  describe "chef_node_delete" do
    it "sets bootstrapped to false" do
      subject.chef_node_delete
      expect(subject.bootstrapped).to be_false
    end
  end

  describe "#complete!" do
    let(:params) {
      {
        "bootstrapped"  => true,
        "joined"        => true,
        "booted"        => true,
      }
    }

    it "Takes a parameter hash and updates the model appropriately" do
      subject.complete! params
      subject.joined.should be_true
      subject.booted.should be_true
    end

    it "Takes a parameter hash including 'terminated' and updates appropriately" do
      subject.complete! params.merge({"terminated" => true})
      subject.booted.should be_false
    end
  end
end

