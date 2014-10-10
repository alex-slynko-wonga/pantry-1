# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :ec2_volume do
    ec2_instance
    size 100
    sequence(:snapshot) { |n| "snap-ab#{344324 + n}" }
    volume_type 'standard'
    sequence(:device_name) do |n|
      device_name = (0..(n / 10)).inject('/dev/sda') { |name, _| name.next }
      "#{device_name}#{n % 10}"
    end
  end

  factory :ec2_volume_for_role, parent: :ec2_volume do
    ec2_instance nil
    instance_role
  end
end
