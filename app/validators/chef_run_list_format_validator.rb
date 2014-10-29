class ChefRunListFormatValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    return if value.nil?
    return unless value.split(/,|\r\n/).any? { |subvalue| invalid_subvalue?(subvalue) }

    object.errors[attribute] << (options[:message] || 'is not formatted properly')
  end

  private

  def invalid_subvalue?(subvalue)
    subvalue[/\A(role\[[-[:alnum:]_]+\]|recipe\[[-[:alnum:]_]+\]|recipe\[[-[:alnum:]_]+(::[-[:alnum:]_]+)?\])\Z/].nil?
  end
end
