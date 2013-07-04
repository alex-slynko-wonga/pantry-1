require 'spec_helper'

describe Ec2InstanceStatusController do
  let(:instance) { FactoryGirl.create(:ec2_instance) }
  describe "GET 'show'" do
    it "returns http success" do
      get 'show', id: instance.id
      response.should be_success
      end
  end
end