RSpec.describe Ec2InstanceCostsController, type: :controller do
  let(:bill_date) { Date.parse('30-11-2013') }
  before(:each) do
    allow(subject).to receive(:signed_in?).and_return(true)
    allow(controller).to receive(:authorize)
  end

  describe "GET 'index'" do
    it 'returns http success' do
      get 'index'
      expect(response).to be_success
    end

    it 'sets available dates from instance costs model' do
      expect(Ec2InstanceCost).to receive(:available_dates).and_return([bill_date])
      get 'index'
      dates = assigns :available_dates
      expect(dates).to eq([['30-11-2013', 'November 2013']])
    end

    context 'with format :json' do
      let(:team) { FactoryGirl.create(:team) }
      let(:ec2_instance) { FactoryGirl.create(:ec2_instance, team: team) }

      it 'returns success' do
        get 'index', bill_date: bill_date
        expect(response).to be_success
      end

      it 'uses costs to get details per team' do
      end
    end
  end

  describe "GET 'show_all'" do
    it 'returns success' do
      get 'index'
      expect(response).to be_success
    end
  end

  describe "GET 'show'" do
    render_views
    let!(:team) { FactoryGirl.create(:team) }
    let(:ec2_instance) { FactoryGirl.create(:ec2_instance, team: team) }

    it 'returns the costs of a team' do
      cost = FactoryGirl.create(:ec2_instance_cost, bill_date: bill_date, ec2_instance: ec2_instance, cost: 100, estimated: nil)
      get 'show', id: team.id, date: '30-11-2013', format: :json
      array_response = JSON.parse(response.body)
      expect(array_response.first['cost']).to eq '100.0'
      expect(array_response.first['ec2_instance_id']).to eq cost.ec2_instance.id
      expect(array_response.first['estimated']).to eq nil
    end
  end
end
