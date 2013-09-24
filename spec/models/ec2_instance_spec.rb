require 'spec_helper'

describe Ec2Instance do
  subject { FactoryGirl.build :ec2_instance }
  it { should be_valid }

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
end
