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

    total_costs = $resource("/total_costs/:date").get({date: $scope.date}, ->
      $scope.total_costs = parseFloat(total_costs.cost)
    )

    costs = $resource("/ec2_instance_costs?date=:date", date: $scope.date).query ->
      $scope.total_pantry_costs = costs.reduce ((total, cost) -> total + parseFloat(cost.costs)), 0
      $scope.costs = costs

]
