require 'spec_helper'

RSpec.describe TotalCostsController, type: :controller do
  before(:each) do
    allow(subject).to receive(:signed_in?).and_return(true)
  end

  context 'GET show' do
    it 'return total cost for selected bill date' do
      cost = FactoryGirl.create(:total_cost)
      get 'show', id: cost.bill_date, format: :json
      expect(response).to be_success
    end
  end
end
