require 'spec_helper'

RSpec.describe Ec2InstanceCostsController, type: :controller do
  before(:each) do
    allow(subject).to receive(:signed_in?).and_return(true)
  end

  describe "GET 'index'" do
    before(:each) do
      allow(controller).to receive(:authorize)
    end

    it 'returns http success' do
      get 'index'
      expect(response).to be_success
    end

    it 'sets costs using Wonga::Pantry::Costs class' do
      expect(Wonga::Pantry::Costs).to receive(:new).and_call_original
      get 'index', format: :json
    end
  end

  describe "GET 'show" do
    render_views
    let!(:team) { FactoryGirl.create(:team) }
    let(:ec2_instance) { FactoryGirl.create(:ec2_instance, team: team) }

    it 'returns the costs of a team' do
      cost = FactoryGirl.create(:ec2_instance_cost, bill_date: Date.parse('30-11-2013'), ec2_instance: ec2_instance, cost: 100, estimated: nil)
      get 'show', id: team.id, date: '30-11-2013', format: :json
      array_response = JSON.parse(response.body)
      expect(array_response.first['cost']).to eq '100.0'
      expect(array_response.first['ec2_instance_id']).to eq cost.ec2_instance.id
      expect(array_response.first['estimated']).to eq nil
    end
  end
end
