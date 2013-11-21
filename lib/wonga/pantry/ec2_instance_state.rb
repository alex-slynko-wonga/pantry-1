class Wonga::Pantry::Ec2InstanceState
  attr_accessor :state_machine, :ec2_instance, :user, :instance_params

  def initialize(ec2_instance = nil, user = nil, instance_params = nil)
    @ec2_instance = ec2_instance
    @user = user
    @instance_params = instance_params
  end

  def change_state
    @state_machine = Wonga::Pantry::Ec2InstanceMachine.new
    @state_machine.state = ec2_instance.state if ec2_instance.state
    
    ["terminated", "bootstrapped", "dns", "joined", "ip_address", "instance_id"].each do |key|
      @ec2_instance[key] = @instance_params[key] if @instance_params.key?(key)
    end

    @state_machine.instance_state = @ec2_instance
    event = prepare_params
    before_state = @state_machine.state
  
    if event && @state_machine.fire_events(event.to_sym)
      @ec2_instance.state = @state_machine.state
      @ec2_instance.ec2_instance_logs.build(from_state: before_state, event: event.to_sym, user: @user)
      @ec2_instance.save
    end
  end

  def state
    @state_machine.state
  end
  
  def self.initial_state
    Wonga::Pantry::Ec2InstanceMachine.new.state
  end

  private
  def prepare_params    
    return @instance_params["event"] if @instance_params["event"]
    
    if @instance_params["booted"]
      "ec2_booted"
    elsif @instance_params["bootstapped"]
      "bootstrap"
    elsif @instance_params.key?("joined")
      @instance_params["joined"] ? "add_to_domain" : "terminated"
    elsif @instance_params["terminated"]
      "terminated"
    end
  end
end
