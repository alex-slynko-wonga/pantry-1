class SecurityGroupIdsLimitValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    if value.nil?
      object.errors[attribute] << (options[:message] || 'cannot be nil')
    elsif value.empty?
      object.errors[attribute] << (options[:message] || 'cannot be empty')
    elsif value.count > 5
      object.errors[attribute] << (options[:message] || 'exceeds limit of security group ids')
    end
  end
end
