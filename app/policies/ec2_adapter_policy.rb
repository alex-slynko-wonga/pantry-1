class Ec2AdapterPolicy < ApplicationPolicy
  def initialize(user)
    @user = user
  end

  def show_all_security_groups?
    god_mode?
  end

  def show_all_subnets?
    god_mode?
  end
end
