require 'spec_helper'

describe Wonga::Pantry::Ec2InstanceState do
  let(:team) { FactoryGirl.build(:team) }
  let(:ec2_instance) { FactoryGirl.build(:ec2_instance, team: team) }
  let(:params) {
    {
      "bootstrapped"  => true,
      "joined"        => true,
      "booted"        => true,
      "instance_id"   => ec2_instance.id
    }
  }
  let(:user) { FactoryGirl.create(:user, team: team)}
  subject { Wonga::Pantry::Ec2InstanceState.new(ec2_instance, user, params) }

  describe "bootstrap" do
    it "changes to bootstrap" do
      ec2_instance.update_attributes(state: "dns_record_created", bootstrapped: false)
      expect(Wonga::Pantry::Ec2InstanceState.new(ec2_instance, user, { "event" => "bootstrap" }).change_state).to be_truthy
    end
  end
  
  describe "store instance variables used in termination_condition" do
    it "stores dns, terminated, bootstrapped, joined" do
      ec2_instance.update_attributes(bootstrapped: true, dns: nil, terminated: nil, joined: nil, state: 'terminating')
      Wonga::Pantry::Ec2InstanceState.new(ec2_instance, user, { 'event' => 'terminated', "bootstrapped" => false, "dns" => true, "terminated" => true, "joined" => true }).change_state
      expect(ec2_instance.reload.bootstrapped).to be_falsey
      expect(ec2_instance.reload.dns).to be_truthy
      expect(ec2_instance.reload.terminated).to be_truthy
      expect(ec2_instance.reload.joined).to be_truthy
    end
  end

  describe "persist the state" do
    it "persists the state returned by the state machine" do
      state = Wonga::Pantry::Ec2InstanceState.new(ec2_instance, user, { "event" => "ec2_boot" })
      state.change_state
      expect(state.ec2_instance.reload.state).to eq "booting"
      ec2_instance.state = "ready"
      state = Wonga::Pantry::Ec2InstanceState.new(ec2_instance, user, { "event" => "termination" })
      state.change_state
      expect(state.ec2_instance.reload.state).to eq "terminating"
    end
  end

  describe "request to change the state" do
    it "changes from initial_state to booting" do
      state = Wonga::Pantry::Ec2InstanceState.new(ec2_instance, user, { "event" => "ec2_boot" })
      state.change_state
      expect(state.state).to eq "booting"
    end

    it "returns true if the change of state is successfull" do
      state = Wonga::Pantry::Ec2InstanceState.new(ec2_instance, user, { "event" => "ec2_boot" })
      expect(state.change_state).to be_truthy
    end

    it "returns false if the change of state fails" do
      state = Wonga::Pantry::Ec2InstanceState.new(ec2_instance, user, { "event" => "terminated" })
      expect(state.change_state).to be_falsey
    end
  end

  describe "move from terminating to terminated" do
    it "moves the state" do
      instance = FactoryGirl.create(:ec2_instance, 
        state:        "terminating", 
        dns:          false, 
        terminated:   true, 
        bootstrapped: false, 
        joined:       false,
        team:          team
      )
      state = Wonga::Pantry::Ec2InstanceState.new(instance, user, {"event" => "terminated"})
      expect(state.change_state).to be_truthy
    end
  end

  describe "logs" do
    it "stores from_state, event, instance and user when passing an event" do
      state = Wonga::Pantry::Ec2InstanceState.new(ec2_instance, user, { "event" => "ec2_boot" })
      state.change_state
      expect(state.ec2_instance.ec2_instance_logs.first.user).to eq(user)
      expect(state.ec2_instance.ec2_instance_logs.first.from_state).to eq("initial_state")
      expect(state.ec2_instance).to eq(ec2_instance)
    end

    it "doesn't store log if no event has been passed" do
      state = Wonga::Pantry::Ec2InstanceState.new(ec2_instance, user, { })
      expect { state.change_state }.to_not change(Ec2InstanceLog, :count)
    end

    it "doesn't store log if state can't be changed" do
      state = Wonga::Pantry::Ec2InstanceState.new(ec2_instance, user, { "event" => "add_to_domain" })
      expect { state.change_state }.to_not change(Ec2InstanceLog, :count)
    end
  end

  describe "get next states" do
    it "returns the states" do
      state = Wonga::Pantry::Ec2InstanceState.new(ec2_instance, user, { "event" => "ec2_boot" })
      state.change_state
      expect { state.can_ec2_booted? }.to be_truthy
    end
  end
end
