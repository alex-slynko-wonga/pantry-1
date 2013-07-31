class Ec2Instance < ActiveRecord::Base  
  belongs_to :team
  belongs_to :user

  validates :name, presence: true
  validates :team_id, presence: true 
  validates :user_id, presence: true
  validates :domain, :presence => true, :domain_name => true
  validates :chef_environment, :presence => true
  validates :run_list, :presence => true, :chef_run_list_format => true

  after_initialize :init, on: :create
  before_create :set_start_time

  def exists!(instance_id)
    self.instance_id = instance_id
    self.save!
  end

  def complete!(status)
    case status 
    when :booted
      self.booted = true
    when :bootstrapped
      self.bootstrapped = true
    when :joined
      self.joined = true
      self.end_time = Time.current
    end
    save!
  end

  def get_status
    {
      booted: self.booted,
      bootstrapped: self.bootstrapped,
      joined: self.joined
    }
  end

  def human_status
    return "Ready" if bootstrapped && joined
    if bootstrapped
      "Bootstrapped"
    elsif joined
      "Joined to domain"
    elsif booted
      "Booted"
    else
      "Booting"
    end
  end
  
  def progress
    return 100 if bootstrapped && joined
    if bootstrapped
      40
    elsif joined
      60
    elsif booted
      20
    else
      0
    end
  end

  private
    def init
      self.booted ||= false
      self.bootstrapped ||= false
      self.joined ||= false
    end

    def set_start_time
      self.start_time = Time.current
    end
end
