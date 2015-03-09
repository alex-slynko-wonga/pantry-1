# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :api_key do
    sequence(:name) { |n| "ApiKey #{n}" }
    key { SecureRandom.uuid }
    permissions %w(api_chef_node)
  end
end
