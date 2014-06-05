require 'spec_helper'

describe Api::Ec2InstancesController do
  describe "#update" do
    let(:team) { FactoryGirl.build(:team) }
    let(:user) { FactoryGirl.build(:user, team: team) }

    context "with valid token" do
      before(:each) do
        request.headers['X-Auth-Token'] = CONFIG['pantry']['api_key']
        @ec2_instance = instance_double('Ec2Instance', id: 45)
        allow(@ec2_instance).to receive(:user).and_return(user)
        allow(Ec2Instance).to receive(:find).with('45').and_return(@ec2_instance)
        @state = instance_double('Wonga::Pantry::Ec2InstanceState')
        allow(Wonga::Pantry::Ec2InstanceState).to receive(:new).and_return(@state)
        @user = instance_double('User', id: 1)
        allow(User).to receive(:find).with(1).and_return(@user)
      end

      it "updates an instance" do
        expect(@state).to receive(:change_state!)
        put :update, id: 45, user_id: 1, terminated: true, format: 'json'
      end

      it "returns http success" do
        allow(@state).to receive(:change_state!)
        put :update, id: 45, user_id: 1, terminated: true, format: 'json', test: false
        expect(response).to be_success
      end
    end
  end

  describe "#update_from_aws" do
    let(:team) { FactoryGirl.build(:team) }
    let(:user) { FactoryGirl.build(:user, team: team) }

    context "with valid token" do
      let(:aws_tags) {
        {
          "Name" => "mocked.aws.instance",
          "pantry_request_id" => "45",
          "team_id" => team.id,
          "user_id" => user.id
        }
      }
      let(:aws_instance) { aws_ec2_mocker_build_instance(status: :shutdown, tags: aws_tags) }
      let(:ec2_instance) { FactoryGirl.build_stubbed(:ec2_instance, :running, id: 45) }
      before(:each) do
        request.headers['X-Auth-Token'] = CONFIG['pantry']['api_key']
        describe_tags_hash = AWS::EC2.new.client.stub_for(:describe_tags)
        describe_tags_hash[:tag_set] = aws_tags.map { |tag_key,tag_value|
          {
            :resource_id => aws_instance.instance_id,
            :resource_type => "instance",
            :key => tag_key,
            :value => tag_value
          }
        }
        describe_tags_hash[:tag_index] = aws_tags.each_with_object({}) do |(tag_key,tag_value), hash|
          hash["instance:#{aws_instance.instance_id}:#{tag_key}"] = {
            :resource_id => aws_instance.instance_id,
            :resource_type => "instance",
            :key => tag_key,
            :value => tag_value
          }
        end
        describe_instances_hash = AWS::EC2.new.client.stub_for(:describe_instances)
        describe_instances_hash[:instance_index] = {
          aws_instance.instance_id => {
            :group_set => aws_instance.security_groups.map { |sg|
              {
                :group_name => sg.name,
                :group_id => sg.security_group_id
              }
            },
            :tag_set => aws_instance.tags.map { |tag_key,tag_value|
              {
                :key => tag_key,
                :value => tag_value
              }
            },
            :instance_id => aws_instance.instance_id,
            :image_id => aws_instance.image,
            :instance_state => {
              :code => aws_instance.status_code,
              :name => aws_instance.status.to_s
            },
            :api_termination_disabled? => aws_instance.api_termination_disabled?,
            :disable_api_termination => aws_instance.api_termination_disabled?,
            :instance_type => aws_instance.instance_type,
            :ip_address => aws_instance.ip_address,
            :platform => aws_instance.platform,
            :private_ip_address => aws_instance.private_ip_address,
            :subnet_id => aws_instance.subnet_id,
            :vpc_id => aws_instance.vpc_id
          }
        }
        describe_instances_hash[:reservation_set] = [
          {
            :reservation_id => "reservation-00000000",
            :instances_set => [ describe_instances_hash[:instance_index][aws_instance.instance_id] ]
          }
        ]
        describe_instance_attribute_hash = AWS::EC2.new.client.stub_for(:describe_instance_attribute)
        describe_instance_attribute_hash[:disable_api_termination] = { value: aws_instance.api_termination_disabled?}
        allow(ec2_instance).to receive(:user).and_return(user)
        allow(Ec2Instance).to receive(:find).with('45').and_return(ec2_instance)
        @state = instance_double('Wonga::Pantry::Ec2InstanceState')
        allow(Wonga::Pantry::Ec2InstanceState).to receive(:new).and_return(@state)
        @user = instance_double('User', id: 1)
        allow(User).to receive(:find).with(1).and_return(@user)
      end
      after(:each) do
        describe_tags_hash = AWS::EC2.new.client.stub_for(:describe_tags)
        describe_tags_hash.clear
        describe_instance_attribute_hash = AWS::EC2.new.client.stub_for(:describe_instance_attribute)
        describe_instance_attribute_hash.clear
        describe_instances_hash = AWS::EC2.new.client.stub_for(:describe_instances)
        describe_instances_hash[:instance_index] = {}
        describe_instances_hash[:reservation_index] = {}
      end

      context "for instance tagged by Pantry" do
        before(:each) do
          allow(ec2_instance).to receive(:update_info).and_return(true)
        end

        it "updates instance" do
          expect(ec2_instance).to receive(:update_info)
          post :update_from_aws, format: :json
        end

        it "returns http success" do
          post :update_from_aws, format: :json
          expect(response).to be_success
        end

        it "returns results in response" do
          post :update_from_aws, format: :json
          expect(JSON.parse(response.body)).to eq({"aws_tagged"=>[], "errors"=>[], "unchanged"=>[], "untagged"=>[], "updated"=>[45]})
        end
      end

      context "for instance tagged by AWS" do
        let(:aws_tags) {
          {
            "Name" => "cf-tagged.mocked.aws.instance",
            "aws:cloudformation:logical-id" => "CFTaggedMockedInstance",
            "aws:cloudformation:stack-id" => "arn:aws:cloudformation:eu-west-1:000000000000:stack/SomeStack/00000000-0e58-11e3-be2f-000000000000",
            "aws:cloudformation:stack-name" => "SomeStack"
          }
        }
        it "returns http success" do
          post :update_from_aws, format: :json
          expect(response).to be_success
        end

        it "returns results in response" do
          post :update_from_aws, format: :json
          expect(JSON.parse(response.body)).to eq({"aws_tagged"=>["i-00001234"], "errors"=>[], "unchanged"=>[], "untagged"=>[], "updated"=>[]})
        end
      end

      context "for untagged instance" do
        let(:aws_tags) {
          {
            "Name" => "untagged.mocked.aws.instance"
          }
        }

        it "does not update an instance" do
          expect(ec2_instance).to_not receive(:update_info)
          post :update_from_aws, format: :json
        end

        it "returns http success" do
          post :update_from_aws, format: :json
          expect(response).to be_success
        end

        it "returns results in response" do
          post :update_from_aws, format: :json
          expect(JSON.parse(response.body)).to eq({"aws_tagged"=>[], "errors"=>[], "unchanged"=>[], "untagged"=>["i-00001234"], "updated"=>[]})
        end
      end
    end
  end
end
