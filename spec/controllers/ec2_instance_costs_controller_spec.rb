require 'spec_helper'

describe Ec2InstanceCostsController do

  describe "GET 'index'" do
    it "returns http success" do
      get 'index'
      response.should be_success
    end
  
    it "sets costs using Wonga::Pantry::Costs class" do
      expect(Wonga::Pantry::Costs).to receive(:new).and_call_original
      get 'index', format: :json
    end
  end

  describe "GET 'show" do
    render_views
    let!(:team) { FactoryGirl.create(:team) }
    let(:ec2_instance) { FactoryGirl.create(:ec2_instance, team: team) }
    
    it "returns the costs of a team" do
      cost = FactoryGirl.create(:ec2_instance_cost, bill_date: Date.parse('30-11-2013'), ec2_instance: ec2_instance, cost: 100, estimated: nil)
      get 'show', id: team.id, date: '30-11-2013', format: :json
      array_response = JSON.parse(response.body)
      array_response.first["cost"].should eq "100.0"
      array_response.first["ec2_instance_id"].should eq cost.ec2_instance.id
      array_response.first["estimated"].should eq nil
    end
  end
end
