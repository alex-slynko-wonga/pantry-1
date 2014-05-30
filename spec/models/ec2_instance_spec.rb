require 'spec_helper'

describe Ec2Instance do
  subject { FactoryGirl.build :ec2_instance }
  it { should be_valid }

  it "should be invalid without attributes (and not raise exception)" do
    expect(Ec2Instance.new).to be_invalid
  end

  it "doesn't validate name if older instance was destroyed" do
    old_instance = FactoryGirl.create(:ec2_instance, :running, name: subject.name)
    expect(subject).to be_invalid
    old_instance.update_attributes(terminated: true, state: 'terminated')
    expect(subject).to be_valid
  end

  it "doesn't validate name if contains spaces" do
    subject.name = "my instance"
    expect(subject).to be_invalid
  end

  context "for linux" do
    subject { FactoryGirl.build(:ec2_instance, :running, platform: 'linux', name: name) }

    context "when name is 63 symbols" do
      let(:name) { "a" + "1"*62 }

      it { should be_valid }

      it "is invalid if the first 15 characters are not unique" do
        subject.save!
        new_instance = FactoryGirl.build(:ec2_instance, name: name[0..15])
        expect(new_instance).to be_invalid
      end
    end

    context "when name is longer than 64 symbols" do
      let(:name) { "a" + "1"*64 }

      it { should be_invalid }
    end
  end

  context "for windows" do
    subject { FactoryGirl.build(:ec2_instance, platform: 'windows', name: name) }

    context "when name is 15 symbols" do
      let(:name) { "a" + "1"*14 }

      it { should be_valid }
    end

    context "when name is longer than 15 symbols" do
      let(:name) { "a" + "1"*15 }

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
  end

  it "should be invalid without run_list" do
    subject.run_list = nil
    expect(subject).to be_invalid
  end

  it "should be invalid with 6 security_group_ids" do
    subject.security_group_ids = ["sg-00000001","sg-00000002","sg-00000003","sg-00000004","sg-00000005","sg-00000006"]
    expect(subject).to be_invalid
  end

  context "if the user does not belogs to the current team" do
    subject { FactoryGirl.build(:ec2_instance, user: FactoryGirl.build(:user), team: FactoryGirl.build(:team)) }
    it { should be_invalid }
  end

  context "if environment is not from current team" do
    subject { FactoryGirl.build(:ec2_instance, environment: Environment.new) }
    it { should be_invalid }
  end

  describe "initial state" do
    it "sets the state to initial_state" do
      expect(described_class.new.state).to eq("initial_state")
    end
  end

  describe "update Pantry instance from AWS" do
    context "info not provided" do
      context "instance_id is unknown" do
        subject { FactoryGirl.create(:ec2_instance, instance_id: nil) }

        it "returns false" do
          expect(subject.update_info).to eq false
        end
      end

      context "instance_id is known" do
        subject { FactoryGirl.create(:ec2_instance, :running, instance_id: "i-00001111", protected: false) }

        context "if instance-id exists in AWS" do
            before(:each) do
              hash = AWS::EC2.new.client.stub_for(:describe_instances)
              hash[:instance_index] = {
                aws_instance.instance_id => {
                  :instance_id => aws_instance.instance_id,
                  :image_id => aws_instance.image,
                  :instance_state => {
                    :code => aws_instance.status_code,
                    :name => aws_instance.status.to_s
                  },
                  :instance_type => aws_instance.instance_type,
                  :ip_address => aws_instance.ip_address,
                  :platform => aws_instance.platform,
                  :private_ip_address => aws_instance.private_ip_address,
                  :subnet_id => aws_instance.subnet_id,
                  :vpc_id => aws_instance.vpc_id
                }
              }
            end

          after(:each) do
            hash = AWS::EC2.new.client.stub_for(:describe_instances)
            hash[:instance_index] = {}
            hash[:reservation_set] = {}
          end

          context "and AWS have no changes" do
            let(:aws_instance) { aws_ec2_mocker_build_instance(status: :stopped,
                                                               status_code: 80,
                                                               instance_id: "i-00001111",
                                                               instance_type: "m0.tiny",
                                                               api_termination_disabled?: true,
                                                               security_groups: [aws_ec2_mocker_build_sg(security_group_id: "sg-00000303"),
                                                                                 aws_ec2_mocker_build_sg(security_group_id: "sg-00000404")],
                                                               private_ip_address: "192.168.168.192") }
            it "runs successfully" do
              expect(subject.update_info).to eq true
            end
          end

          context "and AWS has different info" do
            let(:aws_instance) { aws_ec2_mocker_build_instance(status: :stopped,
                                                               status_code: 80,
                                                               instance_id: "IgnoreMe",
                                                               instance_type: "m0.tiny",
                                                               api_termination_disabled?: true,
                                                               security_groups: [aws_ec2_mocker_build_sg(security_group_id: "sg-00000303"),
                                                                                 aws_ec2_mocker_build_sg(security_group_id: "sg-00000404")],
                                                               private_ip_address: "192.168.168.192") }

            it "updates state" do
              subject.update_info(aws_instance)
              expect(subject.state).to eq("shutdown")
            end

            it "updates security_group_ids" do
              subject.update_info(aws_instance)
              expect(subject.security_group_ids).to eq(["sg-00000303", "sg-00000404"])
            end

            it "updates ip_address" do
              subject.update_info(aws_instance)
              expect(subject.ip_address).to eq(aws_instance.private_ip_address)
            end

            it "updates flavor" do
              subject.update_info(aws_instance)
              expect(subject.flavor).to eq(aws_instance.instance_type)
            end

            it "updates protected" do
              subject.update_info(aws_instance)
              expect(subject.protected).to eq(aws_instance.api_termination_disabled?)
            end
          end
        end

        context "if instance-id does not exist in AWS" do
          before(:each) do
            hash = AWS::EC2.new.client.stub_for(:describe_instances)
            hash[:instance_index] = {}
            hash[:reservation_set] = {}
          end

          it "returns true" do
            expect(subject.update_info).to eq true
          end
        end
      end
    end

    context "info provided" do
      subject { FactoryGirl.create(:ec2_instance, :running, instance_id: "i-00001112", protected: false) }
        context "and AWS have no changes" do
          let(:aws_instance) { aws_ec2_mocker_build_instance(status: :running,
                                                             status_code: 16,
                                                             security_groups: subject.security_group_ids.map { |id| aws_ec2_mocker_build_sg(security_group_id: id) },
                                                             instance_type: subject.flavor,
                                                             api_termination_disabled?: subject.protected,
                                                             private_ip_address: subject.ip_address) }

          it "runs successfully" do
            expect(subject.update_info).to eq true
          end
        end

        context "and AWS has different info" do
          let(:aws_instance) { aws_ec2_mocker_build_instance(status: :stopped,
                                                             status_code: 80,
                                                             instance_id: "IgnoreMe",
                                                             instance_type: "m0.tiny",
                                                             api_termination_disabled?: true,
                                                             security_groups: [aws_ec2_mocker_build_sg(security_group_id: "sg-00000303"),
                                                                               aws_ec2_mocker_build_sg(security_group_id: "sg-00000404")],
                                                             private_ip_address: "192.168.168.192") }

          it "updates state" do
            subject.update_info(aws_instance)
            expect(subject.state).to eq("shutdown")
          end

          it "updates security_group_ids" do
            subject.update_info(aws_instance)
            expect(subject.security_group_ids).to eq(["sg-00000303", "sg-00000404"])
          end

          it "updates ip_address" do
            subject.update_info(aws_instance)
            expect(subject.ip_address).to eq(aws_instance.private_ip_address)
          end

          it "updates flavor" do
            subject.update_info(aws_instance)
            expect(subject.flavor).to eq(aws_instance.instance_type)
          end

          it "updates protected" do
            subject.update_info(aws_instance)
            expect(subject.protected).to eq(aws_instance.api_termination_disabled?)
          end
        end
    end
  end
end
