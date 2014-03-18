class User < ActiveRecord::Base
  ROLES = %w( business_admin superadmin team_admin developer)

  has_many :team_members
  has_many :teams, through: :team_members
  has_many :ec2_instances

  validates :role, presence: true, inclusion: ROLES
  before_validation :set_role, on: :create

  def self.from_omniauth(auth)
    find_by_username(auth['samaccountname'][0]) ||
      create_with_ldap(auth)
  end

  def self.create_with_ldap(auth)
    create! do |user|
      user.username = auth['samaccountname'][0]
      user.name = auth['displayname'][0]
      user.email = auth['mail'][0] if auth['mail']
    end
  end

  def image_url(pixels = 40)
    "https://secure.gravatar.com/avatar/#{Digest::MD5.hexdigest(email)}?s=#{pixels}&d=blank" if email
  end

  def email
    if attributes['email']
      attributes['email'].downcase
    elsif username
      "#{username}@example.com".downcase
    end
  end

  def have_billing_access?
    self.email ==  'jonathan.galore@example.com' ||
      Array(CONFIG['billing_users']).include?(self.email)
  end

  def member_of_team?(team)
    teams.include?(team)
  end

  private
  def set_role
    self.role ||= 'developer'
  end
end
