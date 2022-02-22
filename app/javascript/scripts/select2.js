import $ from "jquery"
import "select2/dist/js/select2"

$(document).on("turbolinks:load", function() {
  $('.js-select2').each(function() {
    const $this = $(this)

    let ops = {
      multiple: true,
      maximumSelectionLength: 3,
      dropdownAutoWidth: true,
      theme: 'classic',
      width: 'resolve',
      debug: 'true'
    }

    $this.select2(ops)
  });
});
