require 'spec_helper'

shared_examples_for "changes state" do
  before(:each) do
    allow(ec2_instance).to receive(:save).and_return(true)
    allow(machine).to receive(:fire_events).and_return(true)
    allow(machine).to receive(:callback)
  end

  it "saves user and event to log" do
    subject
    log = ec2_instance.ec2_instance_logs[-1]
    expect(log.user).to eq(user)
    expect(log.event).to eq(:some_event)
  end

  it "saves instance" do
    subject
    expect(ec2_instance).to have_received(:save)
  end

  it "change additional attributes" do
    subject
    expect(ec2_instance).to be_bootstrapped
    expect(ec2_instance).to be_joined
    expect(ec2_instance.instance_id).to be_present
  end
end

shared_examples_for "doesn't change state" do
  it "doesn't save instance" do
    expect(ec2_instance).not_to receive(:save)
    subject
  end

  it "doesn't log" do
    subject
    expect(ec2_instance.ec2_instance_logs).to be_blank
  end
end

describe Wonga::Pantry::Ec2InstanceState do
  let(:ec2_instance) { FactoryGirl.build_stubbed(:ec2_instance) }
  let(:params) {
    {
      "bootstrapped"  => true,
      "joined"        => true,
      "instance_id"   => ec2_instance.id,
      "event"         => "some_event"
    }
  }
  let(:user) { FactoryGirl.build_stubbed(:user) }
  let(:machine) { instance_double('Wonga::Pantry::Ec2InstanceMachine') }
  subject(:state) { Wonga::Pantry::Ec2InstanceState.new(ec2_instance, user, params) }

  before(:each) do
    allow(Wonga::Pantry::Ec2InstanceMachine).to receive(:new).and_return(machine)
  end

  describe "bootstrap" do
  end

  describe "#change_state" do
    subject { state.change_state }
    include_examples "changes state" do
      context "for old event formats" do
        let(:params) { { "bootstrapped" => true } }

        it "processes" do
          subject
          expect(machine).to have_received(:fire_events).with(:bootstrap)
        end
      end
    end

    context "if event didn't fire" do
      before(:each) do
        allow(machine).to receive(:fire_events).and_return(false)
      end
      include_examples "doesn't change state"
    end

    context "if event is missing" do
      let(:params) { { } }

      include_examples "doesn't change state"
    end
  end

  describe "#change_state!" do
    subject { state.change_state! }
    include_examples "changes state"
    context "if event didn't fired" do
      before(:each) do
        allow(machine).to receive(:fire_events).and_return(false)
      end

      it "raise exception" do
        expect { subject }.to raise_exception
      end
    end

    context "if event is missing" do
      let(:params) { { } }

      it "raise exception" do
        expect { subject }.to raise_exception
      end
    end
  end
end
