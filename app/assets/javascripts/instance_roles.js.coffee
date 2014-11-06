$(document).ready ->
  $("select[id=instance_role_instance_size]").change ->
    disk_size = $(this.options[this.selectedIndex]).data('disk-size')
    disk_size_input = $('#instance_role_disk_size').val()
    default_disk_size_label = $('.instance_role_disk_size .help-block')
    if disk_size_input
      if disk_size?
        default_disk_size_label.show()
        default_disk_size_label.text('default: ' + disk_size)
      else
        default_disk_size_label.hide()
    else
      $('#instance_role_disk_size').val(disk_size)
