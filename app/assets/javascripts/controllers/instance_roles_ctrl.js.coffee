@app.controller 'InstanceRolesCtrl', ["$scope", "$resource", "Ami", "Ec2Volume", ($scope, $resource, Ami, Ec2Volume) ->
  if $scope.preloadResource.ec2_volumes?.length? and $scope.preloadResource.ec2_volumes.length != 0
    $scope.ec2_volumes = ( new Ec2Volume().from_model(volume) for volume in $scope.preloadResource?.ec2_volumes)
  else
    $scope.ec2_volumes = [ new Ec2Volume() ]

  $scope.ami_id = $scope.preloadResource.ami_id
  $scope.updateAmiInfo = ->
    return unless $scope.ami_id
    amiAws = Ami.get ami_id: $scope.ami_id, ->
      $scope.ami = amiAws
      volume_names = (mapping.device_name for mapping in amiAws.block_device_mapping)
      for mapping in amiAws.block_device_mapping when mapping.ebs?
        found = volume.from_mapping(mapping) for volume in $scope.ec2_volumes when mapping.device_name == volume.device_name
        $scope.ec2_volumes.push(new Ec2Volume().from_mapping(mapping)) unless found
      $scope.ec2_volumes = (volume for volume in $scope.ec2_volumes when not volume.automatic || volume.device_name in volume_names)
      $scope

  $scope.removeVolume = (index) ->
    if $scope.ec2_volumes[index].id
      $scope.ec2_volumes[index]['_destroy'] = 1
    else
      $scope.ec2_volumes.splice index, 1

  $scope.addVolume = ->
    $scope.ec2_volumes.push new Ec2Volume()
    false

  $scope.updateAmiInfo()
]
