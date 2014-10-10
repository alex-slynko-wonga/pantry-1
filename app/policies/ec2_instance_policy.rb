class Ec2InstancePolicy < ApplicationPolicy
  def create?
    god_mode? ||
      ((team_member? || record.team.blank?) && !maintenance_mode?)
  end

  def shutdown_now?
    (god_mode? || team_member?) && can_move_with_event(:shutdown_now?)
  end

  def start_instance?
    (god_mode? || team_member?) && can_move_with_event(:start_instance?)
  end

  def destroy?
    (god_mode? || team_member?) && can_move_with_event(:termination?)
  end

  def cleanup?
    (god_mode? || record.user == user) && can_move_with_event(:out_of_band_cleanup?) && !can_move_with_event(:termination?)
  end

  def custom_ami?
    god_mode?
  end

  def custom_volume?
    god_mode?
  end

  def resize?
    (god_mode? || team_member?) && can_move_with_event(:resize?)
  end

  def available?
    god_mode? || team_member?
  end

  def custom_iam?
    god_mode?
  end

  private

  def can_move_with_event(event)
    return false if record.state == 'terminated'
    delegated_method = "can_#{event}"
    state_machine = Wonga::Pantry::Ec2InstanceMachine.new(record)
    state_machine.respond_to?(delegated_method) && state_machine.public_send(delegated_method)
  end
end
