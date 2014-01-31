require 'spec_helper'

describe Ec2InstancesController do
  let(:instance) { FactoryGirl.create(:ec2_instance) }

  describe "GET 'aws_status'" do
    it "returns object with instance status" do
      instance_id = 'instance_id'
      instance_status = double
      expect(Ec2InstanceStatus).to receive(:find).with(instance_id).and_return(instance_status)
      get 'aws_status', id: instance_id, format: :json
      expect(assigns(:ec2_instance_status)).to eq(instance_status)
    end
  end

  describe "GET 'show'" do
    it "returns http success with a html request" do
      get 'show', id: instance.id
      expect(response).to be_success
    end

    it "returns a json hash" do
      expected = {
        "ami" => instance.ami,
        "bootstrapped" => instance.bootstrapped,
        "environment_id" => instance.environment_id,
        "created_at" => instance.created_at,
        "domain" => instance.domain,
        "flavor" => instance.flavor,
        "id" => instance.id,
        "instance_id" => instance.instance_id,
        "joined" => instance.joined,
        "name" => instance.name,
        "platform" => instance.platform,
        "run_list" => instance.run_list,
        "security_group_ids" => instance.security_group_ids,
        "subnet_id" => instance.subnet_id,
        "team_id" => instance.team_id,
        "updated_at" => instance.updated_at,
        "user_id" => instance.user_id,
        "volume_size" => instance.volume_size
      }

      get 'show', id: instance.id, format: :json
      result = JSON.parse(response.body)
      expected.each do |key, value|
        if value.is_a? Time
          expect(value.to_i).to eq(Time.parse(result[key]).to_i)
        else
          expect(value).to eq(result[key])
        end
      end
    end
  end
end
