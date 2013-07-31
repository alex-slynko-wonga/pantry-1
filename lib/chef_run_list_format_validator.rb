class ChefRunListFormatValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    unless value =~ /^(role\[[a-z0-9_]+\]|recipe\[[a-z0-9_]+\]|recipe\[[a-z0-9_]+::[a-z0-9_]*\])$/
      object.errors[attribute] << (options[:message] || "is not formatted properly") 
    end
  end
end