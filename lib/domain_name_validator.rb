require 'resolv'
class DomainNameValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    @domain = nil
    begin
      Resolv::DNS.open do |dns|
        @domain = dns.getresource(value,Resolv::DNS::Resource::IN::NS) 
      end
     rescue Resolv::ResolvError
       object.errors[attribute] << (options[:message] || "is not a valid domain")
    end
  end
end