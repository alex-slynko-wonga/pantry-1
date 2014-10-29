def wait_until(timeout = Capybara.default_wait_time)
  require 'timeout'
  Timeout.timeout(timeout) do
    value = yield
    sleep(0.1) until value
    value
  end
rescue Timeout::Error
  expect(yield).to be true
end
