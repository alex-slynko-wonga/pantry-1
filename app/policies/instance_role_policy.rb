class InstanceRolePolicy < ApplicationPolicy
  Scope = Struct.new(:user, :scope) do
    def resolve
        scope.enabled
    end
  end
end