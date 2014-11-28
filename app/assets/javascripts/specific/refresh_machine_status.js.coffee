$(document).ready refresher = ->
  $("table.table_with_instances").each ->
    $(this).find("td.col_status").each ->
      ec2_id = $(this).data("ec2-id")
      current_state = @innerHTML
      element = this

      # Update current status in column
      $.getJSON("/aws/ec2_instances/check_ec2_instance_state",
        { id: ec2_id },
        (response) ->
          element.innerHTML = response if response != current_state
      ).always ->
        # Schedule the next request when the current one is completed
        setTimeout refresher, 5000