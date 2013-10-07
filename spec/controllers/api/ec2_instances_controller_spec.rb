require 'spec_helper'

describe Api::Ec2InstancesController do

  describe "#create" do
    let(:instance) { FactoryGirl.create(:ec2_instance) }
    let(:params) { { id: instance.id, terminated: true, format: :json } }

    context "without token" do
      it "returns 404" do
        post :update, params
        expect(response.status).to eq 404
      end
    end

    context "with valid token" do
      before(:each) do
        request.env['X-Auth-Token'] = CONFIG['pantry']['api_key']
      end

      it "updates an instance" do
        post :update, params
        instance.reload
        expect(instance.terminated).to eq(true)
      end
    end
  end
end
