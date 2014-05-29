@app.factory "AmiAws", ["$resource", ($resource) ->
  AmiAws = $resource("/aws/ec2_amis/:ami_id.json", {ami_id: "@id"}, {update: {method: "PUT"}})
]

