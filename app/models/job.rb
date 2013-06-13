class Job < ActiveRecord::Base
  validates_inclusion_of :status, :in => %w( pending started completed ), :message => "Status %{value} is not included in the list"
  attr_accessible :description, :end_time, :name, :start_time, :status
end
