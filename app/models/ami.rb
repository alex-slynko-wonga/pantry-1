class Ami < ActiveRecord::Base
  validates_presence_of :name, :platform, :ami_id
  validates_uniqueness_of :name, :ami_id
  validates :platform, inclusion: ['windows', 'linux']
end
