
$(document).ready(function(){

        $('#alert-error-tib').hide();

        $('#user-register-form').submit(function () {
            error = false;
            if (!$('#field-specialconditions').is(':checked')) {
                $('#sc_error_li').show();
                error = true;
                } else {
                    $('#sc_error_li').hide();
                }
            if (!$('#field-dataprotection').is(':checked')) {
                $('#dp_error_li').show();
                error = true;
              } else {
                $('#dp_error_li').hide();
              }
            if (error){
                $('#alert-error-tib').show();
                return false;
            }
        });
    });

