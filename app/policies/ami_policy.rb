class AmiPolicy < ApplicationPolicy
  Scope = Struct.new(:user, :scope) do
    def resolve
      if user.role != 'superadmin'
        scope.visible
      else
        scope
      end
    end
  end
end
