$ ->
  $('div[data-remote-url]').on('change', 'input', ->
    $parent = $(this).parent()
    if this.value
      $.getJSON($parent.data('remote-url').replace(':id', this.value), (data) ->
        setValues($parent, data)
      )
    else
      setValues($parent, {})
  )

setValues = (div, values) ->
  $(div).find('div[data-value]').each (_, element) ->
    $element = $(element)
    $element.text(values[$element.data('value')])

