class Package < ActiveRecord::Base
  attr_accessible :name, :url, :version

  validates :name, presence: true
  validates :url, presence: true
  validates :version, presence: true
end
