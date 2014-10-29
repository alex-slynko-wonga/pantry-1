class DomainNameValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    return if value == CONFIG['pantry']['domain']

    object.errors[attribute] << (options[:message] || "only #{CONFIG['pantry']['domain']} is currently available")
  end
end
