class Ec2InstancePolicy < ApplicationPolicy
  def shutdown_now?
    (god_mode? || @user.teams.include?(@record.team)) && can_move_with_event(:shutdown_now?)
  end

  def start_instance?
    (god_mode? || @user.teams.include?(@record.team)) && can_move_with_event(:start_instance?)
  end

  def destroy?
    (god_mode? || @user.teams.include?(@record.team)) && can_move_with_event(:termination?)
  end

  private
  def can_move_with_event(event)
    delegated_method = "can_#{event}"
    state_machine = Wonga::Pantry::Ec2InstanceMachine.new(@record)
    state_machine.respond_to?(delegated_method) && state_machine.public_send(delegated_method)
  end

end
