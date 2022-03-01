import $ from "jquery"
import "select2/dist/js/select2"

$(document).on("turbolinks:load", function() {
  $('.js-select2').each(function() {
    const $this = $(this)

    let ops = {
      allowClear: true,
      multiple: true,
      maximumSelectionLength: 3,
      dropdownAutoWidth: true,
      theme: 'classic',
      width: 'resolve'
    }

    $this.select2(ops)
  });

  $('#js-switch-period').on("click", function() {
    $("#js-generation").toggleClass("active");
    $("#js-ad").toggleClass("active");
  });
});
