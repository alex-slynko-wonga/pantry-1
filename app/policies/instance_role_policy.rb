class InstanceRolePolicy < ApplicationPolicy
  Scope = Struct.new(:user, :scope) do
    def resolve
      if user.role == 'superadmin'
        scope.all
      else
        scope.enabled
      end
    end
  end
end
