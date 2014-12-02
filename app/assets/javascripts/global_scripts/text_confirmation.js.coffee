$ ->
  $('input[data-confirmation]').on 'keyup', ->
    $(@).parents('form').find('input[type=submit]').prop('disabled', $(@).val() != $(@).data('confirmation'))

