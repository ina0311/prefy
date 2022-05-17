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
    $("#js-generation").toggleClass("no-active");
    $("#js-ad").toggleClass("no-active");
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
