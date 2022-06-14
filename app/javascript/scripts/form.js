import $ from "jquery"
import "select2/dist/js/select2"

$(document).on("turbolinks:load", function() {
  $('[id^="js-select2"]').each(function() {
    const $this = $(this)
    const $parent = $this.attr('id').match(/js-select2-(\w+)/)[1]
    let ops = {
      placeholder: '        ',
      allowClear: true,
      multiple: true,
      closeOnSelect: false,
      maximumSelectionLength: 3,
      dropdownAutoWidth: true,
      dropdownParent: $(`#js-${$parent}`),
      width: 'resolve',
      language: {
        maximumSelected: function (args) {
        var message = args.maximum + ' 件しか選べません';
        return message;
        },
        noResults: function() {
          return '対象が見つかりません';
        }
      }
    }
    $this.select2(ops)
  });

  $('#js-switch-generation, #js-switch-period').on("click", function() {
    $("#js-generation").toggleClass("hidden");
    $("#js-ad").toggleClass("hidden");
  });

  $('#js-switch-number, #js-switch-duration-ms').on("click", function() {
    $("#js-max-number").toggleClass("hidden");
    $("#js-max-duration-ms").toggleClass("hidden");
  });

  $('#js-form-button').on("click", function(){
    $('.hidden').find('option').prop('selected', false);
    $('.hidden').find('input').val(null);
  });
});
