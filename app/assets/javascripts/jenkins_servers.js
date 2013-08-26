this.JenkinsServersCtrl = ["$scope", "$resource", function ($scope, $resource) {
  $scope.instances = [];
    
  $scope.getInstances = function() {
    if($scope.team_id != '') { 
      var team_id = $scope.team_id;
      Instance = $resource("/jenkins_servers?team_id=:team_id", {team_id: team_id});
      $scope.instances = Instance.query();
    }
  };
}]