require 'spec_helper'

describe AwsController do

  describe "GET 'ec2s'" do
    it "returns http success" do
      get 'ec2s'
      response.should be_success
    end
  end

  describe "GET 'amis'" do
    it "returns http success" do
      get 'amis'
      response.should be_success
    end
  end

  describe "GET 'vpcs'" do
    it "returns http success" do
      get 'vpcs'
      response.should be_success
    end
  end

  describe "GET 'security_groups'" do
    it "returns http success" do
      get 'security_groups'
      response.should be_success
    end
  end

end
