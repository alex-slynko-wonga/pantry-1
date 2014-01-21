require 'spec_helper'

describe Wonga::Pantry::Ec2Adapter do
  subject { described_class.new }
  let(:client) { AWS::EC2.new.client }

  context "#platform_for_ami" do
    after(:each) do
      client.instance_variable_set(:@stubs, {})
    end

    it "finds image and gets platform from it" do
      images = client.stub_for(:describe_images)
      images[:images_set] = [{:platform => 'windows'}]
      images[:image_index] = { 'test' => {:platform => 'windows'}}
      expect(subject.platform_for_ami('test', false)).to eq('windows')
    end

    it "returns nil if image can't be found" do
      expect(subject.platform_for_ami('test', false)).to be_nil
    end

    it "returns nil if ami is not provided" do
      images = client.stub_for(:describe_images)
      images[:images_set] = [{:platform => 'windows'}]
      images[:image_index] = { 'test' => {:platform => 'windows'}}
      expect(subject.platform_for_ami(nil, false)).to be_nil
    end

    it "returns linux if ami has no platform parameter" do
      images = client.stub_for(:describe_images)
      images[:images_set] = [{ }]
      images[:image_index] = { 'test' => {}}
      expect(subject.platform_for_ami('test', false)).to eq('linux')
    end
  end
end
