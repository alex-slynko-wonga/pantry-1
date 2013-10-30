require 'spec_helper'

describe Api::CostsController do
  describe "#create" do
    before(:each) do
      request.env['X-Auth-Token'] = CONFIG['pantry']['api_key']
      @ec2_instance = FactoryGirl.create(:ec2_instance)
    end
    
    it "should add the cost" do
      expect {
        post :create, ec2_instance_cost: { bill_date: 1.day.ago, cost: 1234.00, ec2_instance_id: @ec2_instance.id }, format: 'json'
      }.to change(Ec2InstanceCost, :count).by(1)
    end
  end
end
