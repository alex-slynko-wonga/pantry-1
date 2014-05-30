require 'spec_helper'

describe Wonga::Pantry::Ec2InstanceUpdateInfo do
  let(:ec2_instance) { FactoryGirl.create(:ec2_instance, :running) }
  let(:aws_instance) { aws_ec2_mocker_build_instance }
  let(:updater) { described_class.new(ec2_instance, aws_instance) }

  describe "#update_attributes" do
    context "if instance not changed" do
      let(:aws_instance) { aws_ec2_mocker_build_instance(status: :running,
                                              security_groups: ec2_instance.security_group_ids.map { |id| aws_ec2_mocker_build_sg(security_group_id: id) },
                                              instance_type: ec2_instance.flavor,
                                              api_termination_disabled?: ec2_instance.protected,
                                              private_ip_address: ec2_instance.ip_address) }
      it "does not save the record" do
        expect(ec2_instance).to_not receive(:save)
        updater.update_attributes
      end
    end

    context "if instance is changed" do
      let(:aws_instance) { aws_ec2_mocker_build_instance(status: :stopping,
                                              instance_type: "m0.tiny",
                                              api_termination_disabled?: true,
                                              security_groups: [aws_ec2_mocker_build_sg(security_group_id: "sg-00000303"),
                                                                aws_ec2_mocker_build_sg(security_group_id: "sg-00000404")],
                                              private_ip_address: "192.168.168.191") }
      it "updates flavor field" do
        updater.update_attributes
        expect(ec2_instance.flavor).to eq(aws_instance.instance_type)
      end

      it "updates termination protection field" do
        updater.update_attributes
        expect(ec2_instance.protected).to eq(aws_instance.api_termination_disabled?)
      end

      it "updates security group ids field" do
        updater.update_attributes
        expect(ec2_instance.security_group_ids).to eq(["sg-00000303", "sg-00000404"])
      end

      it "saves the ip_address field" do
        updater.update_attributes
        expect(ec2_instance.ip_address).to eq(aws_instance.private_ip_address)
      end

      it "saves the record field" do
        updater.update_attributes
        expect(ec2_instance).to_not be_changed
      end
    end

    context "if AWS instance is terminated" do
      let(:aws_instance) { aws_ec2_mocker_build_instance(status: :terminated) }
      it "updates terminated flag" do
        updater.update_attributes
        expect(ec2_instance.terminated).to eq(true)
      end

      context "and ec2 instance is protected" do
        let(:ec2_instance) { FactoryGirl.create(:ec2_instance, :running, protected: true)}

        it "removes protection" do
          updater.update_attributes
          expect(ec2_instance.protected).to be false
        end
      end
    end
  end

  describe "#update_state" do
    context "if AWS instance is pending" do
      let(:aws_instance) { aws_ec2_mocker_build_instance(status: :pending,
                                              security_groups: ec2_instance.security_group_ids.map { |id| aws_ec2_mocker_build_sg(security_group_id: id) },
                                              instance_type: ec2_instance.flavor,
                                              api_termination_disabled?: ec2_instance.protected,
                                              private_ip_address: ec2_instance.ip_address) }

      context "when Pantry record is in booting state" do
        let(:ec2_instance) { FactoryGirl.create(:ec2_instance, :running, state: "booting") }

        it "does nothing" do
          expect(ec2_instance).to_not receive(:save)
          updater.update_state
          expect(ec2_instance.state).to eq 'booting'
        end
      end
      context "when Pantry record is in ready state" do
        let(:ec2_instance) { FactoryGirl.create(:ec2_instance, :running, state: "ready") }

        it "transitions to starting state" do
          expect(ec2_instance).to receive(:save).at_least(:once)
          updater.update_state
          expect(ec2_instance.state).to eq 'starting'
        end
      end
    end

    context "if AWS instance is running" do
      let(:aws_instance) { aws_ec2_mocker_build_instance(status: :running,
                                              security_groups: ec2_instance.security_group_ids.map { |id| aws_ec2_mocker_build_sg(security_group_id: id) },
                                              instance_type: ec2_instance.flavor,
                                              api_termination_disabled?: ec2_instance.protected,
                                              private_ip_address: ec2_instance.ip_address) }

      context "when Pantry record is in booting state" do
        let(:ec2_instance) { FactoryGirl.create(:ec2_instance, :running, state: "booting") }

        it "does nothing" do
          expect(ec2_instance).to_not receive(:save)
          updater.update_state
          expect(ec2_instance.state).to eq 'booting'
        end
      end

      context "when Pantry record is in ready state" do
        let(:ec2_instance) { FactoryGirl.create(:ec2_instance, :running, state: "ready") }

        it "does nothing" do
          expect(ec2_instance).to_not receive(:save)
          updater.update_state
          expect(ec2_instance.state).to eq 'ready'
        end
      end
    end

    context "if AWS instance is terminating" do
      let(:aws_instance) { aws_ec2_mocker_build_instance(status: :shutting_down,
                                              security_groups: ec2_instance.security_group_ids.map { |id| aws_ec2_mocker_build_sg(security_group_id: id) },
                                              instance_type: ec2_instance.flavor,
                                              api_termination_disabled?: ec2_instance.protected,
                                              private_ip_address: ec2_instance.ip_address) }

      context "when Pantry record is not in terminal state" do
        it "sends termination message" do
          expect(ec2_instance).to receive(:save)
          updater.update_state
          expect(ec2_instance.state).to eq 'terminating'
        end
      end

      context "when Pantry record is in terminating state" do
        let(:ec2_instance) { FactoryGirl.create(:ec2_instance, :running, state: "terminating") }

        it "does nothing" do
          expect(ec2_instance).to_not receive(:save)
          updater.update_state
        end
      end

      context "when Pantry record is in terminated state" do
        let(:ec2_instance) { FactoryGirl.create(:ec2_instance, :terminated) }

        it "does nothing" do
          expect(ec2_instance).to_not receive(:save)
          updater.update_state
        end
      end
    end

    context "if AWS instance is terminated" do
      let(:aws_instance) { aws_ec2_mocker_build_instance(status: :terminated,
                                              security_groups: ec2_instance.security_group_ids.map { |id| aws_ec2_mocker_build_sg(security_group_id: id) },
                                              instance_type: ec2_instance.flavor,
                                              api_termination_disabled?: ec2_instance.protected,
                                              private_ip_address: ec2_instance.ip_address) }

      context "when Pantry record is not in terminal state" do
        it "sends termination message" do
          expect(ec2_instance).to receive(:save)
          updater.update_state
          expect(ec2_instance.state).to eq 'terminating'
        end
      end

      context "when Pantry record is in terminating state" do
        let(:ec2_instance) { FactoryGirl.create(:ec2_instance, :running, state: "terminating") }

        it "does nothing" do
          expect(ec2_instance).to_not receive(:save)
          updater.update_state
        end
      end

      context "when Pantry record is in terminated state" do
        let(:ec2_instance) { FactoryGirl.create(:ec2_instance, :terminated) }

        it "does nothing" do
          expect(ec2_instance).to_not receive(:save)
          updater.update_state
        end
      end
    end
  end
end
