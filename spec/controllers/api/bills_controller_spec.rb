require 'spec_helper'

describe Api::BillsController do

  describe "#create" do
    let(:date) { Date.today }
    let(:params) { { bill_date: date.to_s, total_cost: 10, format: :json } }

    context "without token" do
      it "returns 404" do
        post :create, params
        expect(response.status).to eq 404
      end
    end

    context "with valid token" do
      before(:each) do
        request.env['X-Auth-Token'] = CONFIG['pantry']['api_key']
      end

      it "creates a bill" do
        expect { post :create, params }.to change(Bill, :count).by(1)
      end

      context "when bill with date exists" do
        let!(:record) { FactoryGirl.create(:bill, bill_date: date, total_cost: 5) }

        it "updates that bill" do
          post :create, params
          expect(record.reload.total_cost).to eq(10)
        end
      end
    end
  end
end
