require 'spec_helper'
require "#{Rails.root}/daemons/common/aws_resource"

describe AWSResource do
  context "#find_server_by_id" do
    it "finds server" do
      server = double(id: 1)
      Fog::Compute.stub_chain(:new, :servers).and_return([server])
      expect(subject.find_server_by_id(1)).to eq server
    end
  end
end
