require 'spec_helper'

describe Wonga::Pantry::Ec2Adapter do
  subject { described_class.new(client) }
  let(:client) { AWS::EC2::Client.new }

  context "#platform_for_ami" do
    it "finds image and gets platform from it" do
      images = client.stub_for(:describe_images)
      images[:images_set] = [{:platform => 'windows'}]
      expect(subject.platform_for_ami('test')).to eq('windows')
    end

    it "returns nil if image can't be found" do
      expect(subject.platform_for_ami('test')).to be_nil
    end

    it "returns nil if ami is not provided" do
      images = client.stub_for(:describe_images)
      images[:images_set] = [{:platform => 'Lindows'}]
      expect(subject.platform_for_ami(nil)).to be_nil
    end

    it "returns linux if ami has no platform parameter" do
      images = client.stub_for(:describe_images)
      images[:images_set] = [{ }]
      expect(subject.platform_for_ami('test')).to eq('linux')
    end
  end
end
