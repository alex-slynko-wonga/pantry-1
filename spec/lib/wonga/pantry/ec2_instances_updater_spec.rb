require 'spec_helper'

describe Wonga::Pantry::Ec2InstancesUpdater do
  subject { described_class.new }

  let(:client) { AWS::EC2.new.client }

  after(:each) do
    client.instance_variable_set(:@stubs, {})
  end

  describe "#update_from_aws" do
    let(:team) { FactoryGirl.build(:team) }

    context "with valid token" do
      let(:aws_tags) {
        {
          "Name" => "mocked.aws.instance",
          "pantry_request_id" => "45",
          "team_id" => team.id
        }
      }
      let(:aws_instance) { aws_ec2_mocker_build_instance(status: :shutdown, tags: aws_tags) }
      let(:ec2_instance) { FactoryGirl.build(:ec2_instance, :running, id: 45) }
      before(:each) do
        describe_tags_hash = client.stub_for(:describe_tags)
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
        describe_instances_hash = client.stub_for(:describe_instances)
        describe_instances_hash[:instance_index] = {
          aws_instance.instance_id => {
            :tag_set => aws_instance.tags.map { |tag_key,tag_value|
              {
                :key => tag_key,
                :value => tag_value
              }
            },
            :instance_id => aws_instance.instance_id
          }
        }
        describe_instances_hash[:reservation_set] = [
          {
            :reservation_id => "reservation-00000000",
            :instances_set => [ describe_instances_hash[:instance_index][aws_instance.instance_id] ]
          }
        ]
        allow(Ec2Instance).to receive(:find).with('45').and_return(ec2_instance)
      end

      context "for instance tagged by Pantry" do
        it "updates instance" do
          expect(ec2_instance).to receive(:update_info)
          subject.update_from_aws
        end

        it "returns results in response" do
          expect(subject.update_from_aws).to eq({"aws_tagged"=>[], "errors"=>[], "unchanged"=>[], "untagged"=>[], "updated"=>[45]})
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

        it "does not update an instance" do
          expect(ec2_instance).to_not receive(:update_info)
          subject.update_from_aws
        end

        it "returns results in response" do
          expect(subject.update_from_aws).to eq({"aws_tagged"=>["i-00001234"], "errors"=>[], "unchanged"=>[], "untagged"=>[], "updated"=>[]})
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
          subject.update_from_aws
        end

        it "returns results in response" do
          expect(subject.update_from_aws).to eq({"aws_tagged"=>[], "errors"=>[], "unchanged"=>[], "untagged"=>["i-00001234"], "updated"=>[]})
        end
      end
    end
  end
end
