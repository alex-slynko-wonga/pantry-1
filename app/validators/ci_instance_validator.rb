class CIInstanceValidator < ActiveModel::Validator
  def validate(record)
    return if record.ec2_instance.nil? || record.ec2_instance.environment.nil?
    record.ec2_instance.errors.add(:environment_id, 'Environment should have CI') unless record.ec2_instance.environment.environment_type == 'CI'
  end
end
