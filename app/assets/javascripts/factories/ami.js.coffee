@app.factory "AmiAws", ["$resource", ($resource) ->
  AmiAws = $resource("/aws/ec2_amis/:ami_id.json", {ami_id: "@id"}, {update: {method: "PUT"}})
]

@app.factory "Ami", ["$resource", ($resource) ->
  Ami = $resource("/admin/amis/:ami_id.json", {ami_id: "@id"}, {update: {method: "PUT"}})
]
