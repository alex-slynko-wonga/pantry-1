Before do
  instance_type = instance_double(AwsPricing::InstanceType, memory_in_mb: 1000, virtual_cores: 1, price_per_hour: 0.25)
  allow_any_instance_of(Wonga::Pantry::PricingList).to receive(:get_instance_type).and_return(instance_type)
  allow_any_instance_of(Wonga::Pantry::PricingList).to receive(:get_ec2_on_demand_instance_pricing)
  allow(AwsPricing::InstanceType).to receive(:populate_lookups)
  allow(controller).to receive(:price_list).and_return(Wonga::Pantry::PricingList.new)
end
