class User < ActiveRecord::Base
  has_many :team_members
  has_many :teams, through: :team_members

  def self.from_omniauth(auth)
    find_by_username(auth['samaccountname'][0]) ||
      create_with_ldap(auth)
  end

  def self.create_with_ldap(auth)
    create! do |user|
      user.username = auth['samaccountname'][0]
      user.name = auth['displayname'][0]
      user.email = auth['email'][0] if auth['email']
    end
  end

  def image_url
    "https://secure.gravatar.com/avatar/#{Digest::MD5.hexdigest(email)}?s=40&d=blank" if email
  end

  def email
    if attributes['email']
      attributes['email']
    elsif username
      "#{username}@example.com"
    end
  end
end
