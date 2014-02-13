class Ec2InstancePolicy < ApplicationPolicy
  def create?
    god_mode? || team_member?
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

  def custom_ami?
    god_mode?
  end

  def resize?
    (god_mode? || team_member?) && can_move_with_event(:resize?)
  end

  private
  def can_move_with_event(event)
    delegated_method = "can_#{event}"
    state_machine = Wonga::Pantry::Ec2InstanceMachine.new(record)
    state_machine.respond_to?(delegated_method) && state_machine.public_send(delegated_method)
  end

end
