class Ec2Volume
  size: 50
  device_name: ''
  automatic: true

  from_mapping: (ec2_mapping) ->
    @snapshot_id = ec2_mapping.ebs?.snapshot_id
    @original_size = ec2_mapping.ebs?.volume_size
    @size ||= @original_size
    @size = @original_size if @size < @original_size or @automatic or @_destroy
    @device_name = ec2_mapping.device_name
    @_destroy = false
    @

  from_model: (ec2_model) ->
    @id = ec2_model.id
    @snapshot_id = ec2_model.snapshot
    @size = ec2_model.size
    @device_name = ec2_model.device_name
    @automatic = false
    @_destroy = ec2_model['marked_for_destruction?']
    @
@app.value "Ec2Volume", Ec2Volume
