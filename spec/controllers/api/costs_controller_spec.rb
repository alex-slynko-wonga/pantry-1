require 'spec_helper'

describe Api::CostsController do
  let(:ec2_instance) { FactoryGirl.create(:ec2_instance) }
  let(:bill_date) { "2013-08-31 23:59:00 +0100" }
  
  describe "#create" do
    before(:each) do
      request.env['X-Auth-Token'] = CONFIG['pantry']['api_key']
    end
    
    it "should add the cost" do
      params = {ec2_total: [
          {:estimated => false, :ec2_instance_id => ec2_instance.id, :cost => "23.33"}
        ], bill_date: bill_date }
      expect {
        post :create, params
      }.to change(Ec2InstanceCost, :count).by(1)
    end
    
    it "should update estimated and cost when the record exists" do
      cost = Ec2InstanceCost.create!(:estimated => false, :ec2_instance_id => ec2_instance.id, :cost => "23.33", bill_date: bill_date)

      params = {ec2_total: [
          {:estimated => true, :ec2_instance_id => cost.ec2_instance_id, :cost => "53.33"}
        ], bill_date: bill_date}
      
      expect {
        post :create, params
      }.to_not change(Ec2InstanceCost, :count)
      
      cost.reload
      cost.cost.should eq(BigDecimal("53.33"))
      cost.estimated.should be_true
    end
  end
end
