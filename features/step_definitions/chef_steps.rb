Then(/^a new chef environment should be requested$/) do
  expect(@sqs).to have_received(:send_message)
end

