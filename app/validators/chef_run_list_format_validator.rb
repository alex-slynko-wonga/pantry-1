class ChefRunListFormatValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    return if value.nil?
    if value.split("\r\n").any? { |subvalue| invalid_subvalue?(subvalue) }
      object.errors[attribute] << (options[:message] || "is not formatted properly")
    end
  end

  private
  def invalid_subvalue?(subvalue)
    subvalue[/\A(role\[[a-z0-9_]+\]|recipe\[[a-z0-9_]+\]|recipe\[[a-z0-9_]+::[a-z0-9_]*\])\Z/].nil?
  end
end
