# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
permissions = Rails.application.routes.named_routes.routes.values.select { |node| node.name[/(?=api)(?!api_key)/] }.map(&:name)
ApiKey.create(name: 'Default key', key: CONFIG['pantry']['api_key'], permissions: permissions)
