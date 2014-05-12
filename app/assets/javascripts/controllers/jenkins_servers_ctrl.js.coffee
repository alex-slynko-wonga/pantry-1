@JenkinsServersCtrl = ["$scope", "$resource", ($scope, $resource) ->
  $scope.instances = []
  $scope.getInstances = ->
    unless $scope.team_id is ""
      team_id = $('#single_team_id').attr('data-team_id') # load default team if possible
      team_id = $scope.team_id unless team_id? # otherwise get selected team
      if team_id?
        Instance = $resource("/jenkins_servers.json?team_id=:team_id", team_id: team_id)
        $scope.instances = Instance.query()
]
