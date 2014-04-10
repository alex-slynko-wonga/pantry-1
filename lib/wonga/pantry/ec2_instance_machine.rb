module Wonga
  module Pantry
    class Ec2InstanceMachine
      attr_reader :ec2_instance

      def initialize(ec2_instance)
        @ec2_instance = ec2_instance
        super()
      end

      state_machine :state, :initial => :initial_state do
        event :ec2_boot do
          transition :initial_state => :booting
        end

        event :ec2_booted do
          transition :booting => :booted
        end

        event :add_to_domain do
          transition :booted => :added_to_domain
        end

        event :create_dns_record do
          transition :added_to_domain => :dns_record_created
        end

        event :bootstrap do
          transition :dns_record_created => :ready
        end

        event :shutdown_now do
          transition :ready => :shutting_down
        end

        event :shutdown do
          transition :shutting_down => :shutdown
        end

        event :start_instance do
          transition :shutdown => :starting
        end

        event :started do
          transition :starting => :ready
        end

        event :termination do
          transition [:ready, :shutdown] => :terminating, if: :instance_unprotected
        end

        event :terminated do
          transition :terminating => :terminated, :if => :termination_condition
          transition :terminating => :terminating, unless: :termination_condition
        end

        event :resize do
          transition [:ready, :shutdown, :shutting_down] => :resizing
        end

        event :resized do
          transition :resizing => :starting
        end

        after_transition on: :bootstrap do |machine, state|
          Ec2Notifications.machine_created(machine.ec2_instance).deliver
        end
      end

      def state
        @ec2_instance.state
      end

      private

      def state=(val)
        @ec2_instance.state = val
      end

      def termination_condition
        @ec2_instance[:dns] == false && @ec2_instance[:terminated] == true &&
        @ec2_instance[:bootstrapped] == false && @ec2_instance[:joined] == false &&
        @ec2_instance[:protected] != true
      end

      def instance_unprotected
        @ec2_instance[:protected] != true
      end
    end
  end
end
