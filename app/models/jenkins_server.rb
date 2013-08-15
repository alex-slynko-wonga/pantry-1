class JenkinsServer < ActiveRecord::Base
  belongs_to :Team
  # attr_accessible :title, :body
end
