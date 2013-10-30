Given(/^I am a manager$/) do
  config =  Marshal.load(Marshal.dump(CONFIG))
  config['billing_users'] ||= []
  config['billing_users'] << User.first.email
  stub_const('CONFIG', config)
  page.visit current_path
end

