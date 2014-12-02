# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :api_key do
    sequence(:name) { |n| "ApiKey #{n}" }
    key '3e475446-210a-479a-b7b9-a459dcf157e7'
    permissions %w(api_chef_node)
  end
end
