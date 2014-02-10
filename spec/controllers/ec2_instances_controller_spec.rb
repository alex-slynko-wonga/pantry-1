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

    it "returns http success with a json hash" do
      get 'show', id: instance.id, format: :json
      expect(response).to be_success
    end
  end
end
