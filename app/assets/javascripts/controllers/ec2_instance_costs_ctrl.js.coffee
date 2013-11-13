@Ec2InstanceCostsCtrl = ["$scope", "$resource", ($scope, $resource) ->
  $scope.date = null
  $scope.dateUI = ''

  $scope.getCosts = ->
    $scope.team_id = null # hide the details
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
      $scope.total_pantry_costs = (costs.reduce ((total, cost) -> total + parseFloat(cost.costs)), 0).toFixed(2)
      $scope.costs = costs
  
  $scope.showDetails = (team_id, name)->
    $scope.team_id = team_id
    $scope.name = name
    CostDetail = $resource("/ec2_instance_costs/:team_id?date=:date", team_id: $scope.team_id, date: $scope.date)
    $scope.cost_details = CostDetail.query()
    $scope.render_estimated = "* costs are estimated" unless $scope.cost_details.size > 0 && $scope.cost_details[0].estimated? && $scope.cost_details[0].estimated == true
]
