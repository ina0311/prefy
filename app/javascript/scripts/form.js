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

  $('#js-switch-generation').on("click", function() {
    $("#js-generation").removeClass("no-active");
    $("#js-ad").addClass("no-active");
  });

  $('#js-switch-period').on("click", function() {
    $("#js-generation").addClass("no-active");
    $("#js-ad").removeClass("no-active");
  });

  $('#js-switch-number').on("click", function() {
    $("#js-max-number").removeClass("no-active");
    $("#js-max-duration-ms").addClass("no-active");
  });

  $('#js-switch-duration-ms').on("click", function() {
    $("#js-max-number").addClass("no-active");
    $("#js-max-duration-ms").removeClass("no-active");
  });

  $('#js-form-button').on("click", function(){
    $('.no-active').find('option').prop('selected', false);
    $('.no-active').find('input').val(null);
  });
});
