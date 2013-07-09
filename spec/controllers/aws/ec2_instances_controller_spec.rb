require 'spec_helper'

describe Aws::Ec2InstancesController do
  context "#new" do
    it "Should be success" do
      get :new
      expect(response).to be_success
    end
  end

  context "#create" do
    it "Should redirect" do
      post :create
      expect(response).to be_redirect
    end
  end
end
