require 'rspec/expectations'

RSpec::Matchers.define :permit do |expected|
  match do |actual|
    actual.send(expected)
  end

  description do
    "permit #{expected} action"
  end

   failure_message_for_should do |actual|
     "expected to permit #{expected} action"
   end

   failure_message_for_should_not do |actual|
     "expected to permit #{expected} action"
   end
end

