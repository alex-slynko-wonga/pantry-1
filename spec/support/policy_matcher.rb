require 'rspec/expectations'

module Pundit
  module RSpec
    def self.action_sentence(actions)
      "#{actions.join(',')} #{'action'.pluralize(actions.size)}"
    end

    module Matchers
      extend ::RSpec::Matchers::DSL

      matcher :permit do |*actions|
        match do |policy|
          if actions.present?
            check_permission(policy, actions)
          else
            check_permission(policy, permissions)
          end
        end

        description do
          if actions.present?
            "permit #{Pundit::RSpec.action_sentence(actions)}"
          else
            "be permitted"
          end
        end

        failure_message_for_should do |actual|
          if actions.present?
            "expected to permit #{Pundit::RSpec.action_sentence(@not_permitted)}"
          else
            "expected to be permitted"
          end
        end

        failure_message_for_should_not do |actual|
          if actions.present?
            "expected not to permit #{Pundit::RSpec.action_sentence(@permitted)} "
          else
            "expected not to be permitted"
          end
        end

        def permissions
          @permissions ||= ::RSpec.current_example.metadata[:permissions]
        end

        def check_permission(policy, permissions)
          @permitted = permissions.select { |permission| policy.public_send(permission) }
          @not_permitted = permissions - @permitted
          @permitted.any?
        end
      end
    end

    module DSL
      def permissions(*list, &block)
        describe("#{Pundit::RSpec.action_sentence(list)}", :permissions => list, :caller => caller) { instance_eval(&block) }
      end

      alias :permission :permissions
    end

    module PolicyExampleGroup
      include Pundit::RSpec::Matchers

      def self.included(base)
        base.metadata[:type] = :policy
        base.extend Pundit::RSpec::DSL
        super
      end
    end
  end
end

RSpec.configure do |config|
  config.include Pundit::RSpec::PolicyExampleGroup, :type => :policy, :example_group => {
    :file_path => /spec\/policies/
  }
end
