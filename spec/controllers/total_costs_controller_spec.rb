require 'spec_helper'

describe TotalCostsController do
  context "GET show" do
    it "return total cost for selected bill date" do
      cost = FactoryGirl.create(:total_cost)
      get 'show', id: cost.bill_date, format: :json
      expect(response).to be_success
    end
  end
end
