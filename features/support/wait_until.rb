def wait_until(timeout = Capybara.default_wait_time)
  require 'timeout'
  Timeout.timeout(timeout) do
    sleep(0.1) until value = yield
    value
  end
rescue Timeout::Error
  expect(yield).to be true
end
