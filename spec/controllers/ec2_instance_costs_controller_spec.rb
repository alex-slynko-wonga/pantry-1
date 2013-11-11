require 'spec_helper'

describe Ec2InstanceCostsController do

  describe "GET 'index'" do
    it "returns http success" do
      get 'index'
      response.should be_success
    end

    it "sets costs using Wonga::Pantry::Costs class" do
      expect(Wonga::Pantry::Costs).to receive(:new).and_call_original
      get 'index'
    end
  end
end
