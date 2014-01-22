require 'spec_helper'
require 'json'

describe Aws::Ec2AmisController do
  let(:ami_id) { "ami-01010101" }
  let(:ami_attributes) {
    {
      "name" => "test-ami",
      "platform" =>"windows"
    }
  }
  describe "GET 'show'" do
    let(:adapter) { instance_double('Wonga::Pantry::Ec2Adapter', get_ami_attributes: ami_attributes) }

    before(:each) do
      allow(Wonga::Pantry::Ec2Adapter).to receive(:new).and_return(adapter)
    end

    it "returns nothing for no ami" do
      get 'show', id: "", :format => :json
      expect(adapter).to have_received(:get_ami_attributes)
      expect(response).to be_success
    end

    it "returns info for an ami" do
      get 'show', id: ami_id, :format => :json
      expect(adapter).to have_received(:get_ami_attributes).with(ami_id)
      expect(response).to be_success
      expect(response.body).to eq ami_attributes.to_json
    end
  end
end
