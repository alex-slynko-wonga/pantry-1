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

  it "validates name that it is long enough" do
    subject.name = "1" * 20
    expect(subject).to be_invalid
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
    { booting: "Booting", booted: 'Booted', joined: 'Joined', bootstrapped: 'Bootstrapped', terminated: 'Terminated', ready: 'Ready' }.each do |state, human_name|
      it "is '#{human_name}' when instance is #{state}" do
        subject.state = state.to_s
        expect(subject.human_status).to eq(human_name)
      end
    end
    
    it "returns a default value if the state is nil" do
      instance = FactoryGirl.build(:ec2_instance, state: nil)
      instance.save(validate: false) # say we have a dodgy state, i.e. nil
      instance.human_status.should eq("Initial state")
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
  
  describe "intial state" do
    it "sets the state to initial_state" do
      params = {
        "name"=>"NameInitialState",
        "instance_id"=>"MyString",
        "team_id"=>nil,
        "ami"=>"i-111111",
        "flavor"=>"t1.micro",
        "booted"=>nil,
        "bootstrapped"=>nil,
        "joined"=>nil,
        "subnet_id"=>"subnet-00110011",
        "security_group_ids"=>["sg-00000001", "sg-00000002", "sg-00110010"],
        "domain"=>"example.com",
        "chef_environment"=>"InitialStateEnvironment",
        "run_list"=>"role[ted]\r\nrecipe[ted]\r\nrecipe[ted::something]",
        "platform"=>"Lindows",
        "volume_size"=>10,
        "ip_address"=>"pending",
        "state"=>nil
      }
      Ec2Instance.new(params).state.should eq("initial_state")
    end
  end
end

