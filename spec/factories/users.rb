# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    ignore do
      team nil
    end
    username "MyString"

    after(:build) do |user, evaluator|
      if evaluator.team
        user.teams << evaluator.team
      end
    end
  end
end
