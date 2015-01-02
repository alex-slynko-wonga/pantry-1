@app.controller 'JenkinsServersCtrl', ["$scope", "$resource", ($scope, $resource) ->
  $scope.instances = []
  $scope.getInstances = ->
    $scope.team_id = $scope.preloadResource.team_id
    if $scope.team_id isnt ""
      team_id = $scope.team_id
      Instance = $resource("/jenkins_servers.json?team_id=:team_id", team_id: team_id)
      $scope.instances = Instance.query()
]
