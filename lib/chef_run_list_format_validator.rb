class ChefRunListFormatValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    if value.split("\r\n").any?{|subvalue| subvalue[/\A(role\[[a-z0-9_]+\]|recipe\[[a-z0-9_]+\]|recipe\[[a-z0-9_]+::[a-z0-9_]*\])\Z/].nil?} 
      object.errors[attribute] << (options[:message] || "is not formatted properly") 
    end
  end
end