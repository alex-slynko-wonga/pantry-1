class Job < ActiveRecord::Base
  has_many :job_logs
  belongs_to :package

  validates_inclusion_of :status, :in => %w( pending started completed ), :message => "Status %{value} is not included in the list"

  before_validation do
    self.status ||= 'pending'
  end

  after_create do
    Delayed::Job.enqueue RunChefClientJob.new(self.id, 'chef-client')
  end

  def start!
    self.status = 'started'
    self.start_time = Time.now
    self.save!
  end

  def complete!
    self.status = 'completed'
    self.end_time = Time.now
    self.save!
  end

  def job_status
    case status
    when 'started'
      "Started at #{start_time}"
    when "completed"
      "Completed at #{end_time}"
    else
      "Pending since #{created_at}"
    end
  end

end
