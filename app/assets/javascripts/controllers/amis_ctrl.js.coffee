@AmisCtrl = ["$scope", "$http", "AmiAws", "validation", ($scope, $http, AmiAws, validation) ->
  $scope.setAmi = (ami_id, name, platform, platform_was) ->
    return unless ami_id
    $scope.ami =
      ami_id: ami_id
      name: name
      platform: platform
      platform_was: platform_was
    amiAws = AmiAws.get ami_id: ami_id, ->
      $scope.aws_ami = amiAws

  $scope.getAmiInfo = ->
    clearTimeout($scope.amiTimeout) if $scope.amiTimeout
    $scope.amiTimeout = null
    validation.reset($scope)
    $scope.aws_ami = null
    $scope.amiTimeout = setTimeout( ->
      $scope.amiTimeout = null
      amiAws = AmiAws.get(ami_id: $scope.ami.ami_id, ->
        $scope.aws_ami = amiAws
        $scope.ami.name = amiAws.name unless $scope.ami.name
        $scope.ami.platform = amiAws.platform
      )
    , 100)


]

