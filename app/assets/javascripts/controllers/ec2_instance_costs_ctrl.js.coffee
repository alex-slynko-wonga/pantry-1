@Ec2InstanceCostsCtrl = ["$scope", "$resource", ($scope, $resource) ->
  $scope.date = null
  $scope.dateUI = ''
  
  $scope.getCosts = ->
    $scope.options = JSON.parse($('#Ec2InstanceCostsCtrl').attr('data-bill_dates'))
    unless $scope.date?
      $scope.date = $scope.options[0][0]
      $scope.dateUI = $scope.options[0][1]
    else
      $scope.dateUI = $('#change_date option:selected').text()

    Cost = $resource("/ec2_instance_costs?date=:date", date: $scope.date)
    $scope.costs = Cost.query()
]