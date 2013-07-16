require 'spec_helper'

shared_examples "bootstrap with runner" do
  before(:each) do
    runner.stub(:add_host)
    runner.stub(:run_commands)
  end

  it "runs chef_client command" do
    expect(runner).to receive(:run_commands).with('chef-client')
    subject.perform
  end

  it "connects to machine" do
    expect(runner).to receive(:add_host).with(address)
    subject.perform
  end
end

describe Ec2Bootstrap do
  subject { Ec2Bootstrap.new(1) }
  context "#perform" do
    let(:instance) { double }
    let(:address) { 'some.address' }

    before(:each) do
      AWSResource.stub_chain(:new, :find_server_by_id).and_return(instance)
      instance.stub(:private_dns_name).and_return(address)
    end

    context "for linux machine" do
      let(:runner) { instance_double('SshRunner') }

      before(:each) do
        instance.stub(:platform)
        SshRunner.stub(:new).and_return(runner)
      end

      it_should_behave_like "bootstrap with runner"
    end

    context "for windows machine" do
      let(:runner) { instance_double('WinRMRunner') }

      before(:each) do
        instance.stub(:platform).and_return('windows')
        WinRMRunner.stub(:new).and_return(runner)
      end

      it_should_behave_like "bootstrap with runner"
    end
  end
end
