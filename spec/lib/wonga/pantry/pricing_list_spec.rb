require 'spec_helper'

RSpec.describe Wonga::Pantry::PricingList do

  let(:flavors) { { 't1.supermicro' => 10 } }
  let(:virtual_cores) { 1 }
  let(:price) { 0.123 }
  let(:ram) { 256 }
  let(:instance_type) { instance_double(AwsPricing::InstanceType, memory_in_mb: ram, virtual_cores: virtual_cores) }

  context '#retrieve_price_list' do
    before(:each) do
      expect_any_instance_of(Wonga::Pantry::PricingList).to receive(:get_instance_type).and_return(instance_type)
      allow_any_instance_of(Wonga::Pantry::PricingList).to receive(:get_ec2_on_demand_instance_pricing)
      allow(instance_type).to receive(:price_per_hour).and_return(price)
      allow(AwsPricing::InstanceType).to receive(:populate_lookups)
    end

    it 'returns hash with instance details' do
      expect(subject.retrieve_price_list(flavors)).to eq('t1.supermicro' => { 'windows_price' => "#{price} $/hr",
                                                                              'linux_price' => "#{price} $/hr",
                                                                              'virtual_cores' => virtual_cores,
                                                                              'ram' => "#{ram / 1000.to_f} GB",
                                                                              'disk_size' => 10 })
    end
  end
end
