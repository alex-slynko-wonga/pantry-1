module Wonga
  module Pantry
    class Ec2InstanceMachine
      attr_reader :ec2_instance

      def initialize(ec2_instance)
        @ec2_instance = ec2_instance
        @custom_callbacks = []
        super()
      end

      state_machine :state, initial: :initial_state do
        event :ec2_boot do
          transition initial_state: :booting
        end

        event :ec2_booted do
          transition booting: :booted
        end

        event :add_to_domain do
          transition booted: :added_to_domain
        end

        event :create_dns_record do
          transition added_to_domain: :dns_record_created
        end

        event :bootstrap do
          transition [:dns_record_created, :ready] => :ready
        end

        event :shutdown_now do
          transition ready: :shutting_down
        end

        event :shutdown do
          transition shutting_down: :shutdown
          transition shutting_down_automatically: :shutdown_automatically
        end

        event :shutdown_now_automatically do
          transition ready: :shutting_down_automatically
        end

        event :start_instance do
          transition shutdown: :starting
          transition shutdown_automatically: :starting
        end

        event :start_instance_automatically do
          transition shutdown_automatically: :starting
        end

        event :started do
          transition starting: :ready
        end

        event :out_of_band_cleanup do
          transition all - [:terminating, :terminated]  => :terminating, if: :instance_unprotected
          transition terminated: :terminated
        end

        event :termination do
          transition [:ready, :shutting_down, :shutting_down_automatically, :shutdown,
                      :shutdown_automatically, :starting, :resizing] => :terminating, if: :instance_unprotected
        end

        event :terminated do
          transition terminating: :terminated, if: :termination_condition
          transition terminating: :terminating, unless: :termination_condition
          transition terminated: :terminated
        end

        event :resize do
          transition [:ready, :shutdown, :shutting_down, :shutdown_automatically, :shutting_down_automatically] => :resizing
        end

        event :resized do
          transition resizing: :starting
        end

        after_transition dns_record_created: :ready do |machine, _state|
          mail = Ec2Notifications.machine_created(machine.ec2_instance)
          machine._add_callback(-> { mail.deliver_now })
          machine.ec2_instance.schedule_next_event
        end

        after_transition terminating: :terminated do |machine, _state|
          if machine.ec2_instance.jenkins_slave
            machine._add_callback(-> { machine.delete_jenkins_slave })
          end
        end

        after_transition to: [:shutdown_automatically, :ready] do |machine, _state|
          machine.ec2_instance.schedule_next_event
        end

        after_transition to: :shutdown do |machine, _state|
          machine.ec2_instance.scheduled_event.destroy if machine.ec2_instance.scheduled_event
        end

        after_transition to: :terminating do |machine, _state|
          if machine.ec2_instance.instance_schedule && machine.ec2_instance.scheduled_event
            machine.ec2_instance.scheduled_event.destroy
          end
        end
      end

      def state
        @ec2_instance.state
      end

      def callback
        @custom_callbacks.each(&:call)
      end

      def delete_jenkins_slave
        jenkins_server = @ec2_instance.jenkins_slave.jenkins_server
        server_fqdn = "#{jenkins_server.ec2_instance.name}.#{jenkins_server.ec2_instance.domain}"
        Wonga::Pantry::JenkinsSlaveDestroyer.new(@ec2_instance.jenkins_slave, server_fqdn, 80, @user).delete
      end

      attr_writer :user

      def _add_callback(lambda_or_proc)
        @custom_callbacks << lambda_or_proc
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
