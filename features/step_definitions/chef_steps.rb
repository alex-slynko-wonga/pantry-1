Then(/^a new chef environment should be requested$/) do
  expect(AWS::SQS.new.client).to have_received(:send_message)
end


