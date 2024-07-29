var scheming_multiple_text_init_done = false;

this.ckan.module('scheming-multiple-text', function($, _) {
  var MultipleText = {
    multiple_add: function(field_name) {
      var fieldset = $('fieldset[name=' + field_name + ']');
      var list = fieldset.find('ol');
      var items = list.find('li');
      var copy = items.last().clone();
      var input = copy.find('input');
      input.val('');
      input.attr('data-stored-value', '');
      list.append(copy);
      input.focus();

      // Bind input event to store the input value and print to console
      input.on('input', function() {
        var currentValue = $(this).val();
        $(this).data('stored-value', currentValue);
        console.log('Input value:', currentValue);
      });
    },

    initialize: function() {
      if (!scheming_multiple_text_init_done) {
        $(document).on('click', 'a[name="multiple-add"]', function(e) {
          e.preventDefault();
          var field_name = $(this).attr('data-field-name');
          MultipleText.multiple_add(field_name);
        });

        $(document).on('click', 'a[name="multiple-remove"]', function(e) {
          var list = $(this).closest('ol').find('li');
          if (list.length != 1) {
            var $curr = $(this).closest('.multiple-text-field');
            $curr.hide(100, function() {
              $curr.remove();
            });
            e.preventDefault();
          } else {
            list.first().find('input').val('').data('stored-value', '');
          }
        });

        // Bind input event for existing input fields and print to console
        $('fieldset ol li input').on('input', function() {
          var currentValue = $(this).val();
          $(this).data('stored-value', currentValue);
          console.log('Input value:', currentValue);
        });

        scheming_multiple_text_init_done = true;
      }
    }
  };

  return MultipleText;
});
