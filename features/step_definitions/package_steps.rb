Given(/^a build agent has provided a package of name "(.*?)" with version "(.*?)" placed on url "(.*?)"$/) do |name, version, url|
  page.driver.post "/packages", {name: name, version: version, url: url}
end