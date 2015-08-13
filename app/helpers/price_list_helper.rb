module PriceListHelper
  def flavor_with_size_input(form, price_list, ec2_adapter, name = :flavor)
    if price_list
      price_data = price_list.map do |size, prices|
        [
          size,
          size,
          {
            data: {
              windows_price: prices['windows_price'],
              linux_price: prices['linux_price'],
              cores: prices['virtual_cores'],
              ram: prices['ram']
            }
          }
        ]
      end

      input = form.input name, wrapper_html: { class: 'instance_role_subvalue' } do
        form.select name, price_data, include_blank: true
      end
      (input + render(partial: 'shared/ec2_instance_flavor_details')).html_safe
    elsif ec2_adapter
      form.input(name, collection: ec2_adapter.flavors.keys, wrapper_html: { class: 'instance_role_subvalue' }).html_safe
    end
  end
end
