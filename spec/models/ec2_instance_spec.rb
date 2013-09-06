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
end
