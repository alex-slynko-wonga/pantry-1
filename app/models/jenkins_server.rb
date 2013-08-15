class JenkinsServer < ActiveRecord::Base
  validates :team, presence: true
  belongs_to :team
end
