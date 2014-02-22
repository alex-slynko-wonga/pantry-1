$ ->
  $('input[data-confirmation]').on('keyup', ->
    $(@).next('input[type=submit]').disabled = $(@).value == $(@).data('confirmation')
  )

