class Wonga::Pantry::Ec2InstanceUpdateInfo
  def initialize(ec2_instance, aws_ec2_instance_info = nil)
    @ec2_instance = ec2_instance
    @aws_ec2_instance_info = aws_ec2_instance_info || get_info_from_aws
    @state_machine = Wonga::Pantry::Ec2InstanceMachine.new(@ec2_instance)
  end

  def update_attributes
    return false unless aws_ec2_instance_booted?
    @ec2_instance.attributes = map_ec2_attributes
    if @ec2_instance.changed?
      @ec2_instance.ec2_instance_logs.build(updates: @ec2_instance.changes, user: nil)
      @ec2_instance.save
    end
    true
  end

  def update_state
    return false unless aws_ec2_instance_booted?
    map_ec2_status_to_transitions.each do |transition|
      before_state = @ec2_instance.state
      status = @aws_ec2_instance_info.status.to_s

      if @state_machine.fire_events(transition.event)
        @ec2_instance.ec2_instance_logs.build(from_state: before_state, event: transition.event.to_s, updates: @ec2_instance.changes, user: nil)
        if @ec2_instance.save
          @state_machine.callback
        end
      else
        Rails.logger.error("Error mapping #{status} through #{transition.event.to_s} from #{before_state}")
      end
    end
    true
  end

  private
  def get_info_from_aws
    if @ec2_instance.instance_id.blank?
      Rails.logger.info("Unable to query AWS for #{@ec2_instance.name} without known EC2 instance-id")
      return nil
    end
    AWS::EC2.new.instances[@ec2_instance.instance_id]
  end

  def map_ec2_attributes
    output = Hash.new
    if aws_ec2_instance_terminated?
      output["terminated"] = true
      output["protected"] = false
    end

    if @aws_ec2_instance_info.exists?
      output["flavor"] = @aws_ec2_instance_info.instance_type
      output["ip_address"] = @aws_ec2_instance_info.private_ip_address
      output["protected"] = @aws_ec2_instance_info.api_termination_disabled?
      output["security_group_ids"] = @aws_ec2_instance_info.security_groups.map(&:security_group_id)
      # Skipping this corner case for now, if resized manually must then also be updated manually through rails console
      #output["volume_size"] = @aws_ec2_instance_info.block_device_mappings[@aws_ec2_instance_info.root_device_name].volume.size
    end
    output
  end

  def map_ec2_status_to_transitions
    if aws_ec2_instance_terminated?
      Wonga::Pantry::Ec2Resource.new(@ec2_instance, nil).out_of_band_cleanup
      return []
    end
    return [] if [ "initial_state", "booting", "booted", "added_to_domain", "dns_record_created" ].include?(@ec2_instance.state)
    transitions = case @aws_ec2_instance_info.status
    when :pending
      unless [ "starting", "resizing", "resized" ].include?(@ec2_instance.state)
        @state_machine.state_paths(:from => @ec2_instance.state.to_sym, :to => :starting).first
      end
    when :running
      unless [ "ready" ].include?(@ec2_instance.state)
        @state_machine.state_paths(:from => @ec2_instance.state.to_sym, :to => :ready).first
      end
    when :stopping
      unless [ "shutting_down", "rebooting", "resizing" ].include?(@ec2_instance.state)
        @state_machine.state_paths(:from => @ec2_instance.state.to_sym, :to => :shutting_down).first
      end
    when :stopped
      unless [ "shutdown", "rebooting", "resizing", "resized" ].include?(@ec2_instance.state)
        @state_machine.state_paths(:from => @ec2_instance.state.to_sym, :to => :shutdown).first
      end
    end
    transitions || []
  end

  def aws_ec2_instance_terminated?
    !@aws_ec2_instance_info.exists? || @aws_ec2_instance_info.status == :terminated || @aws_ec2_instance_info.status == :shutting_down
  end

  def aws_ec2_instance_booted?
    @aws_ec2_instance_info.present?
  end
end
