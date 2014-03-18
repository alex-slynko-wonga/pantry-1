angular.module("textFilters", []).filter "conditionalText", ->
  (input, value) ->
    value if input
