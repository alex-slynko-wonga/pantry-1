angular.module('Pantry').factory('validation', [ ->
  validation =
    reset:
      (scope) ->
        $(".control-group").each (index) ->
          scope.errors = {}
          css_class = $(this).attr("class").replace(" error", "")
          $(this).attr "class", css_class
          return
    set:
      (data, scope) ->
        scope.errors = data
        for id of data
          $('.'+id).attr('class', 'control-group string required '+id+' error') if data[id].length
])
