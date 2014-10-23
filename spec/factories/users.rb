# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    transient do
      team nil
    end
    sequence(:username) { |n| "User#{n}" }
    role 'developer'

    callback(:after_build, :after_stub) do |user, evaluator|
      user.teams << evaluator.team if evaluator.team
    end
  end

  factory :superadmin, parent: :user do
    role 'superadmin'
  end
end
