FactoryGirl.define do
  factory :instance_schedule do
    transient do
      start_time nil
      shutdown_time nil
      weekend_only false
    end

    ec2_instance

    schedule do
      attrs = { team: ec2_instance.team, weekend_only: weekend_only, strategy: @build_strategy.class }
      attrs[:start_time] = start_time if start_time
      attrs[:shutdown_time] = shutdown_time if shutdown_time
      association(:schedule, attrs)
    end
  end
end
