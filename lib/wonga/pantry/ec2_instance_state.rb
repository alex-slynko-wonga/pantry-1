class Wonga::Pantry::Ec2InstanceState
  def initialize(ec2_instance = nil, user = nil, instance_params = nil)
    @ec2_instance = ec2_instance
    @user = user
    @instance_params = instance_params
    @state_machine = Wonga::Pantry::Ec2InstanceMachine.new(@ec2_instance)
  end

  def change_state
    %w(terminated bootstrapped dns joined ip_address instance_id flavor).each do |key|
      @ec2_instance[key] = @instance_params[key] if @instance_params.key?(key)
    end

    event = prepare_params

    @ec2_instance.errors.add(:base, 'Event is not provided') unless event

    before_state = @ec2_instance.state

    unless event && @state_machine.fire_events(event)
      @ec2_instance.errors.add(:base, 'State machine did not fire event')
      return
    end

    @ec2_instance.ec2_instance_logs.build(from_state: before_state, event: event, updates: @ec2_instance.changes, user: @user)

    return unless @ec2_instance.save

    @state_machine.user = @user
    @state_machine.callback
    true
  end

  def change_state!
    fail @ec2_instance.errors.inspect unless change_state
  end

  private

  def prepare_params
    return @instance_params['event'].to_sym if @instance_params['event']

    if @instance_params['bootstrapped']
      :bootstrap
    elsif @instance_params.key?('joined')
      @instance_params['joined'] && @instance_params['joined'] != 'false'  ? :add_to_domain : :terminated
    elsif @instance_params['terminated']
      :terminated
    end
  end
end
