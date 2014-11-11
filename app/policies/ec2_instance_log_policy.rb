class Ec2InstanceLogPolicy < ApplicationPolicy
  Scope = Struct.new(:user, :scope) do
    def resolve
      scope.sorted
    end
  end
end
