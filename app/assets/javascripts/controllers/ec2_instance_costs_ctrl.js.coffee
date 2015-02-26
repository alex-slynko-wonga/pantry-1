@app.controller 'Ec2InstanceCostsCtrl', ["$scope", "$resource", ($scope, $resource) ->
  $scope.date = null
  $scope.dateUI = ''
  $scope.teamSortOrder = 'name'
  $scope.instanceSortOrder = 'name'

  $scope.getCosts = ->
    $scope.options = $scope.preloadResource.bill_dates
    $scope.team_id = null # hide the details
    if $scope.date?
      $scope.dateUI = $('#change_date option:selected').text()
    else
      $scope.date = $scope.preloadResource.bill_dates[0][0]
      $scope.dateUI = $scope.preloadResource.bill_dates[0][1]

    total_costs = $resource("/total_costs/:date.json").get({date: $scope.date}, ->
      $scope.total_costs = parseFloat(total_costs.cost)
    )

    costs = $resource("/ec2_instance_costs.json?date=:date", date: $scope.date).query ->
      $scope.costs = $scope.convert_column_to_number(costs, 'costs', 'parsed_costs')
      $scope.total_pantry_costs = ($scope.costs.reduce ((total, cost) -> total + cost.parsed_costs), 0).toFixed(2)
      $scope.teamSortOrder = $scope.teamSortOrder * -1
      $scope.sortTeamsBy $scope.teamSortOrder
      $scope.costs

  $scope.showDetails = (team_id, name, disabled)->
    $scope.team_id = team_id
    $scope.name = name
    $scope.disabled = disabled
    costs = $resource("/ec2_instance_costs/:team_id.json?date=:date", team_id: $scope.team_id, date: $scope.date).query ->
      $scope.cost_details = $scope.convert_column_to_number(costs, 'cost', 'parsed_cost')
      $scope.render_estimated = "* costs are estimated" unless $scope.cost_details.size > 0 && $scope.cost_details[0].estimated? && $scope.cost_details[0].estimated == true
      $scope.instanceSortOrderDirection = $scope.instanceSortOrderDirection * -1
      $scope.sortInstancesBy $scope.instanceSortOrder

  $scope.showDetailsForAllTeams = () ->
    $scope.team_id = null
    $scope.name = 'All instances'
    costs = $resource("/ec2_instance_costs/show_all.json?date=:date", date: $scope.date).query ->
      $scope.cost_details = $scope.convert_column_to_number(costs, 'cost', 'parsed_cost')
      $scope.render_estimated = "* costs are estimated" unless $scope.cost_details.size > 0 && $scope.cost_details[0].estimated? && $scope.cost_details[0].estimated == true
      $scope.instanceSortOrderDirection = $scope.instanceSortOrderDirection * -1
      $scope.sortInstancesBy $scope.instanceSortOrder

  $scope.sortInstancesBy = (column) ->
    if $scope.instanceSortOrder == column
      $scope.instanceSortOrderDirection = $scope.instanceSortOrderDirection * -1
    else
      $scope.instanceSortOrderDirection = 1
      $scope.instanceSortOrder = column
    $scope.cost_details.sort (first, second) ->
      $scope.sortFunction(first, second, $scope.instanceSortOrder) * $scope.instanceSortOrderDirection

  $scope.sortTeamsBy = (column) ->
    if $scope.teamSortOrder == column
      $scope.teamSortOrderDirection = $scope.teamSortOrderDirection * -1
    else
      $scope.teamSortOrderDirection = 1
      $scope.instanceSortOrder = column
    $scope.teamSortOrder = column
    $scope.costs.sort (first, second) ->
      $scope.sortFunction(first, second, $scope.teamSortOrder) * $scope.teamSortOrderDirection

  $scope.sortFunction = (firstUnconverted, secondUnconverted, columnName) ->
    first = firstUnconverted[columnName]
    second = secondUnconverted[columnName]

    if first == second
      0
    else if first < second
      -1
    else
      1

  $scope.convert_column_to_number = (array, original, converted) ->
    array.map (element) ->
      element[converted] = parseFloat(element[original], 2)
      element
]
