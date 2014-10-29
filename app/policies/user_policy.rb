class UserPolicy < ApplicationPolicy
  def update?
    god_mode?
  end

  def see_queues?
    god_mode?
  end

  def admin?
    god_mode?
  end
end
