require 'spec_helper'

describe Api::CostsController do
  let(:ec2_instance) { FactoryGirl.create(:ec2_instance) }
  let(:bill_date) { "2013-08-31 23:59:00 +0100" }

  describe "#create" do
    before(:each) do
      request.env['X-Auth-Token'] = CONFIG['pantry']['api_key']
    end

    it "should add the total cost" do
      params = {ec2_total: [], bill_date: bill_date, total_cost: "1500" }
      expect {
        post :create, params
      }.to change(TotalCost, :count).by(1)
    end

    it "changes existsing cost" do
      total_cost = FactoryGirl.create(:total_cost, bill_date: bill_date, cost: 50)
      params = {ec2_total: [], bill_date: bill_date, total_cost: "1500" }
      expect {
        post :create, params
      }.to_not change(TotalCost, :count)
      expect(total_cost.reload.cost).to eq(BigDecimal("1500"))
    end

    it "should add the cost" do
      params = {ec2_total: [
          {:estimated => false, :instance_id => ec2_instance.id, :cost => "23.33"}
        ], bill_date: bill_date, total_cost: "1500" }
      expect {
        post :create, params
      }.to change(Ec2InstanceCost, :count).by(1)
    end

    it "should update estimated and cost when the record exists" do
      cost = Ec2InstanceCost.create!(:estimated => false, :ec2_instance_id => ec2_instance.id, :cost => "23.33", bill_date: bill_date)

      params = {ec2_total: [
          {:estimated => true, :instance_id => cost.ec2_instance_id, :cost => "53.33"}
        ], bill_date: bill_date, total_cost: "1500" }

      expect {
        post :create, params
      }.to_not change(Ec2InstanceCost, :count)

      cost.reload
      expect(cost.cost).to eq(BigDecimal("53.33"))
      expect(cost).to be_estimated
    end
  end
end
