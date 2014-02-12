class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    false
  end

  def show?
    scope.where(:id => record.id).exists?
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  def god_mode?
    user.role == 'superadmin'
  end

  def team_member?
    user.teams.include?(record.team)
  end

  def as_json(params = nil)
    public_methods(false).select { |name| name[/\?$/] }.each_with_object({}) do |name, hash|
      result = public_send(name)
      hash[name[0..-2].to_sym] = result if result
    end
  end
end

