class JenkinsServer < ActiveRecord::Base
  validates :Team, presence: true
  belongs_to :Team
end
