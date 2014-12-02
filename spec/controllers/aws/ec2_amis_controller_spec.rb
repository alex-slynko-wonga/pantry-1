require 'spec_helper'

RSpec.describe Aws::Ec2AmisController, type: :controller do
  let(:user) { instance_double('User', id: 1, role: 'dev') }
  let(:ami_id) { 'ami-01010101' }
  let(:ami_attributes) do
    {
      'name' => 'test-ami',
      'platform' => 'windows'
    }
  end

  describe "GET 'show'" do
    let(:adapter) { instance_double('Wonga::Pantry::Ec2Adapter', get_ami_attributes: ami_attributes) }

    before(:each) do
      allow(Wonga::Pantry::Ec2Adapter).to receive(:new).with(user).and_return(adapter)
      allow(User).to receive(:find).and_return(user)
    end

    context "when ami doesn't exist" do
      let(:ami_attributes) { {} }

      it 'returns not found' do
        get 'show', id: 'ami-0101', format: :json
        expect(adapter).to have_received(:get_ami_attributes)
        expect(response).to be_not_found
      end
    end

    it 'returns info for an ami' do
      get 'show', id: ami_id, format: :json
      expect(adapter).to have_received(:get_ami_attributes).with(ami_id)
      expect(response).to be_success
      expect(JSON.parse(response.body)).to eq ami_attributes
    end
  end
end
