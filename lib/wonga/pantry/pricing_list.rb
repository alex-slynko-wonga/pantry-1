class Wonga::Pantry::PricingList < AwsPricing::Ec2PriceList
  def initialize
    @_regions = {}
    AwsPricing::InstanceType.populate_lookups
    get_ec2_on_demand_instance_pricing
  end

  @@OS_TYPES = [:linux, :mswin] # rubocop:disable all

  def retrieve_price_list(flavors)
    region = AWS.config.region

    begin
      flavors.each_with_object({}) do |item, pricing_hash|
        instance_type = get_instance_type(region, item.first)
        ram = "#{instance_type.memory_in_mb / 1000.to_f} GB" if instance_type.memory_in_mb
        pricing_hash[item.first] = { 'windows_price' => "#{instance_type.price_per_hour(:mswin, :ondemand)} $/hr",
                                     'linux_price' => "#{instance_type.price_per_hour(:linux, :ondemand)} $/hr",
                                     'virtual_cores' => instance_type.virtual_cores || '-',
                                     'ram' => ram || '-',
                                     'disk_size' => item.second }
      end
    rescue
      nil
    end
  end
end
