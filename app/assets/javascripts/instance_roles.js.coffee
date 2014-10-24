$(document).ready ->
  $("select[id=instance_role_instance_size]").change ->
    disk_size = $(this.options[this.selectedIndex]).data('disk-dize')
    disk_size_input = $('#instance_role_disk_size').val()
    if disk_size_input
      $('.instance_role_disk_size .help-block').text('default: ' + disk_size)
    else
      $('#instance_role_disk_size').val(disk_size)