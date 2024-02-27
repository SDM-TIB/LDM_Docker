
this.ckan.module('scheming-tib-autoupdate-resources-sel-tool', function($, _) {
  MultipleText = {
    initialize: function () {
      console.log("I've been initialized for element: ", this.el);
      //alert("running module");


      var container = this;
      var $this = $(this.el);

      var autoupdate_div = $('#resource_autoupdate_div');
      var select_obj = $('#field-auto_update');
      var input_url_obj = $('#field-auto_update_url');
      var label_auto_update_field = $('label[for="field-auto_update"]');
      var label_auto_update_url_field = $('label[for="field-auto_update_url"]');

      var div_obj = $('label[for="field-auto_update_url"]:parent');
      var upload_label = $('label[for="field-image-url"]');

      var label_html = label_auto_update_url_field.html();
      var required_html = '<span title="This field is required" class="control-required">*</span> ';

      var autoupdate_enabled = autoupdate_div.attr("resource_autoupdate_enabled")=="True";

    // Update 'required' label in Update URL
    // *************************************
      if (select_obj.val()=='No') {
        label_auto_update_url_field.html(label_html);
        } else {
        label_auto_update_url_field.html(required_html+label_html);
        }

    // Function for enabling form elements
    // ************************************
      function enable_form(){
            if(autoupdate_enabled){
            select_obj.removeAttr('disabled');
            select_obj.removeClass('disabled');
            input_url_obj.removeAttr('disabled');
            label_auto_update_field.removeClass("ur_form_disabled");
            label_auto_update_url_field.removeClass("ur_form_disabled");
            } else disable_form();
        }

    // Function for disabling form elements
    // ************************************
    function disable_form(){
            select_obj.attr('disabled', 'disabled');
            select_obj.addClass('ur_form_disabled');
            input_url_obj.attr('disabled', 'disabled')
            label_auto_update_field.addClass("ur_form_disabled");
            label_auto_update_url_field.addClass("ur_form_disabled");

    }

    // Change event on type of resource selection (file or link)
    //**********************************************************
    upload_label.on('DOMSubtreeModified', function(){
     if(!(upload_label.html()=='File')){
        disable_form();
    } else {
        enable_form();
    }
    });

    // Change event on select type of resource update (NO, daily...)
    //**************************************************************
    select_obj.change(function() {
    if ($(this).val()!='No') {
      label_auto_update_url_field.html(required_html+label_html);
    } else {
        label_auto_update_url_field.html(label_html);
    }
  });

    upload_label.trigger('DOMSubtreeModified');

    }

  }

return MultipleText;

});