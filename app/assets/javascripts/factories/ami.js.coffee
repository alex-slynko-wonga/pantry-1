@app.factory "Ami", ["$resource", ($resource) ->
  Ami = $resource("/aws/ec2_amis/:ami_id.json?use_pantry_id=true", {ami_id: "@id"}, {update: {method: "PUT"}})
]

