$ ->
  refresher = ->
    checks = []
    $('table.table_with_instances').not($('div[style*="height: 0px;"] table.table_with_instances')).each ->
      $(this).find("td.col_status").each ->
        # Check non-collapsed items only and be able to check non-collabsible tables (with no .accordion class)
        return if $(this).parents(".accordion").length && !$(this).parents(".collapse.in").length
        # Check if elemnt is visible in a Viewport
        return unless $(this).visible( false, true )
        ec2_id = $(this).data("ec2-id")
        current_state = @innerHTML
        element = this

        # Update current status in column
        checks << $.getJSON("/aws/ec2_instances/check_ec2_instance_state",
          { id: ec2_id },
          (response) ->
            element.innerHTML = response if response != current_state
        )
    # Schedule the next request when the current one is completed
    $.when( checks ).done ->
      setTimeout refresher, 60000
  if $('table.table_with_instances').length > 0
    refresher()
