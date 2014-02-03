require 'spec_helper'

describe Ec2Instance do
  subject { FactoryGirl.build :ec2_instance }
  it { should be_valid }

  it "should be invalid without attributes (and not raise exception)" do
    expect(Ec2Instance.new).to be_invalid
  end

  it "doesn't validate name if older instance was destroyed" do
    old_instance = FactoryGirl.create(:ec2_instance, name: subject.name)
    expect(subject).to be_invalid
    old_instance.update_attribute(:terminated, true)
    expect(subject).to be_valid
  end

  context "for linux" do
    subject { FactoryGirl.build(:ec2_instance, platform: 'linux', name: name) }

    context "when name is 63 symbols" do
      let(:name) { "1"*63 }

      it { should be_valid }
    end

    context "when name is longer than 64 symbols" do
      let(:name) { "1"*64 }

      it { should be_invalid }
    end
  end

  context "for windows" do
    subject { FactoryGirl.build(:ec2_instance, platform: 'windows', name: name) }

    context "when name is 15 symbols" do
      let(:name) { "1"*15 }

      it { should be_valid }
    end

    context "when name is longer than 15 symbols" do
      let(:name) { "1"*16 }

      it { should be_invalid }
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
      expect(subject.error_on(:domain).size).to eq(1)
    end
  end

  context "#human_status" do
    { booting: "Booting", booted: 'Booted', joined: 'Joined', bootstrapped: 'Bootstrapped', terminated: 'Terminated', ready: 'Ready' }.each do |state, human_name|
      it "is '#{human_name}' when instance is #{state}" do
        subject.state = state.to_s
        expect(subject.human_status).to eq(human_name)
      end
    end

    it "returns a default value if the state is nil" do
      instance = FactoryGirl.build(:ec2_instance, state: nil)
      instance.save(validate: false) # say we have a dodgy state, i.e. nil
      expect(instance.human_status).to eq("Initial state")
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

  it "is invalid if the user does not belogs to the current team" do
    user = FactoryGirl.build(:user)
    instance = FactoryGirl.build(:ec2_instance, user: user, team: FactoryGirl.build(:team))
    expect(instance).to be_invalid
  end

  it "is invalid when environment is not from current team" do
    instance = FactoryGirl.build_stubbed(:ec2_instance, environment: Environment.new)
    expect(instance).to be_invalid
  end

  describe "intial state" do
    it "sets the state to initial_state" do
      params = {
        "name"=>"NameInitialState",
        "instance_id"=>"MyString",
        "ami"=>"i-111111",
        "flavor"=>"t1.micro",
        "subnet_id"=>"subnet-00110011",
        "security_group_ids"=>["sg-00000001", "sg-00000002", "sg-00110010"],
        "domain"=>"example.com",
        "run_list"=>"role[ted]\r\nrecipe[ted]\r\nrecipe[ted::something]",
        "platform"=>"Lindows",
        "volume_size"=>10,
        "ip_address"=>"pending"
      }
      expect(Ec2Instance.new(params).state).to eq("initial_state")
    end
  end
end

