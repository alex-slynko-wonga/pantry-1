angular.module('Pantry').directive 'preloadResource', ->
  link: ($scope, element, attrs) ->
    $scope.preloadResource ||= {}
    $scope.preloadResource[attrs.preloadResourceName] = JSON.parse(attrs.preloadResource)
    element.remove()

