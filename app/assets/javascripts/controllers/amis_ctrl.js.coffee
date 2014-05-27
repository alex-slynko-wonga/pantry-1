@AmisCtrl = ["$scope", "$http", "Ami", "AmiAws", "validation", ($scope, $http, Ami, AmiAws, validation) ->
  $scope.setAmi = (ami_id) ->
    return unless ami_id
    amiAws = AmiAws.get(ami_id: ami_id, ->
      $scope.ami = amiAws
    )
    ami = Ami.get(ami_id: ami_id, ->
      $scope.Ami = ami
    )

  $scope.getAmiInfo = ->
    validation.reset($scope)
    $scope.ami = null
    $scope.Ami.name = null
    $scope.Ami.platform = null
    amiAws = AmiAws.get(ami_id: $scope.Ami.ami_id, ->
      $scope.ami = amiAws
      $scope.Ami.name = amiAws.name
      $scope.Ami.platform = amiAws.platform
    )

  $scope.addAmi = ->
    ami = new Ami(ami_id: $scope.Ami.ami_id, name: $scope.Ami.name, hidden: $scope.Ami.hidden, platform: $scope.Ami.platform)
    ami.$save({},
      () -> window.location = "/admin/amis", # on success
      (data, status, headers, config) ->  # on error
        validation.set(data, $scope)
    )

  $scope.updateAmi = ->
    $http.put("/admin/amis/" + $('#ami_id').val() + ".json", {name: $('#name').val(), hidden: $('#hidden').prop('checked')}
    ).success(
      -> window.location = "/admin/amis"
    ).error(
      (data, status, headers, config) ->
        validation.set(data, $scope)
    )
]

