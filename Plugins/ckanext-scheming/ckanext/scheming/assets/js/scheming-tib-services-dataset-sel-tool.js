// Enable JavaScript's strict mode. Strict mode catches some common
// programming errors and throws exceptions, prevents some unsafe actions from
// being taken, and disables some confusing and bad JavaScript features.

this.ckan.module('scheming-tib-services-dataset-sel-tool', function($, _) {
  MultipleText = {
    initialize: function () {
      console.log("I've been initialized for element: ", this.el);
      //alert("running module");

      var container = this;
      var $this = $(this.el);

      var $source_inputs = $this.find('input[element_type="input_source"]');
      var $org_inputs = $this.find('input[element_type="input_org"]');
      var $ds_inputs = $this.find('input[element_type="input_ds"]');
      var $chkall_buttons = $this.find('a[element_type="button_checkall"]');
      var $result_var = $this.find("#field-datasets_served_list");
      var $result_p_test = $this.find("#result_p");

      var $help_button = $this.find('#btn_help_ds_sel_tool');
      var help_content = $this.find('#btn_help_ds_sel_tool_content').html();

      // Initialize Help Popover
      $help_button.on('click',function(e) { e.preventDefault(); });
      $help_button.popover({'content': help_content, 'html': true} );

      // Initialize selected checkboxes
      ds_sel_tool_update_result();

      // Change event on source inputs(checkboxes)
      // ****************************************
      $source_inputs.on('change', function(e) {
            //alert("Enter new show_source");
          $this_obj = $(this);
          source_type = $this_obj.val(); // local or LHU
          if($this_obj.is(':checked')){
             // Checking the source
             // Select DS from source for that his org is checked
             src = "input[ds_source='"+source_type+"']";
             dataset_objs = $(src).filter(function() {
                org = '#chk_org_' + $(this).attr('org');
                return $(org).is(':checked');
             });
            // Show those DS
            dataset_objs.parent().show();

          } else {
            // Unchecking the source
            // Select DS from source (org checked or not)
            src = "input[ds_source='"+source_type+"'";
            dataset_objs = $(src)
            // Hide DS
            dataset_objs.parent().hide();
        }
        ds_sel_tool_update_result();
      });

      // Change event on organization inputs(checkboxes)
      //************************************************
      $org_inputs.on('change', function(e) {
          //alert("Enter new show_org");
          $this_obj = $(this);

          if($this_obj.is(':checked')){
            // Checking the organization
            // Select DS from org for that his source is checked
            src = "input[org='"+$this_obj.val()+"']";
            dataset_objs = $(src).filter(function() {
                src = '#chk_src_' + $(this).attr('ds_source');
                return $(src).is(':checked');
            });
            // Show those DS
            dataset_objs.parent().show();
          } else {
            // Unchecking the org
            // Select DS from org (source checked or not)
            src = "input[org='"+$this_obj.val()+"']";
            dataset_objs = $(src)
            // Hide DS
            dataset_objs.parent().hide();
          }
          ds_sel_tool_update_result();
      });

      // Change event on datasets inputs(checkboxes)
      //********************************************
      $ds_inputs.on('change', function(e) {
            ds_sel_tool_update_result();
      });

      // Click event on "check_all/none" buttons
      // ***************************************
      $chkall_buttons.on('click', function(e) {
          //alert("Enter new check_all none");

          e.preventDefault();
          $obj_call = $(this);
          check_all_flag = $obj_call.attr("check_all");
          obj_call_type =  $obj_call.attr("ds_sel_tool_checkall_type");

          if (obj_call_type == 'source'){
                obj_input_id = "#"+$obj_call.attr('id').replace("btn_help_ds_sel_tool_","chk_src_");
                $obj_input = $(obj_input_id);
                check_source($obj_input, (check_all_flag=='true'));
          } else if(obj_call_type=='org') { // obj type 'org'
                obj_input_id = "#"+$obj_call.attr('id').replace("btn_help_ds_sel_tool_org_","chk_org_");
                $obj_input = $(obj_input_id);
                check_org($obj_input, (check_all_flag=='true'));
            } else if(obj_call_type=='orgs'){
                check_all_orgs((check_all_flag=='true'));
               } else { // obj_type is ds
                    check_all_ds((check_all_flag=='true'));
               }

          // change check_all status of component
          val = check_all_flag;
          if (val=='false') { val = 'true'; } else { val = 'false' };
          $obj_call.attr("check_all", val);

          // update result
          ds_sel_tool_update_result();
      });

      // Update Result
      // *************
      function ds_sel_tool_update_result(){
        // alert("entra update");
        result = "";

        $ds_inputs.each(function(){
            obj_parent_visible = $(this).parent().is(":visible");
            obj_checked = $(this).is(":checked");
            if(obj_parent_visible && obj_checked) {
                if(result!="") result += ",";
                result += $(this).val(); // id for final version
                //result += $(this).attr('org')+"-"+$(this).attr('ds_source')+"-"+$(this).attr('id');
            }
        });

        //  alert("result:  "+result);
        $result_var.val(result);
        //   alert($("#ds_sel_tool_result").val());
        $result_p_test.html($result_var.val());

    }

    // Check all datasets from "source" check_all/none button
    // ******************************************************
    function check_source(obj, check) {
          //alert("Enter new check_source");
          $this_obj = obj;

          if ($this_obj.is(':checked')) {
            // Checking the source
            // Select DS from source for that his org is checked
            src = "input[ds_source='"+$this_obj.val()+"']";
            dataset_objs = $(src).filter(function() {
                org = '#chk_org_' + $(this).attr('org');
                return $(org).is(':checked');
            });
            if (check) {
                // Check those DS
                dataset_objs.prop('checked', true);
            } else {
                // Uncheck
                dataset_objs.prop('checked', false);
            }
            ds_sel_tool_update_result();
          } else {
                // Do nothing - let them as they are
            }

    }

    // Check all datasets from "organization" check_all/none button
    // ************************************************************
    function check_org(obj, check) {

          $this_obj = obj;

          if ($this_obj.is(':checked')) {
            // Checking the organization
            // Select DS from org for that his source is checked
            src = "input[org='"+$this_obj.val()+"']";
            $dataset_objs = $(src).filter(function() {
                src = '#chk_src_' + $(this).attr('ds_source');
                return $(src).is(':checked');
            });

            if (check) {
                // Check those DS
                $dataset_objs.prop('checked', true);
            } else {
                // Uncheck
                $dataset_objs.prop('checked', false);
            }
            ds_sel_tool_update_result();
          } else {
            // Do nothing - let them as they are
          }
    }


    // Check all datasets from "organization" check_all/none button
    // ************************************************************
    function check_all_orgs(check) {

          src = "input[ds_sel_tool_input_type='org']";
          $dataset_objs = $(src)

          if(check){ // check all
                $dataset_objs.prop('checked', true);
          } else {
            $dataset_objs.prop('checked', false);
          }

          $dataset_objs.each(function(){
             $(this).trigger('change');
          });
    }

    // Check all datasets from "organization" check_all/none button
    // ************************************************************
    function check_all_ds(check) {

          src = "input[ds_sel_tool_input_type='ds']";
          $dataset_objs = $(src)

          $dataset_objs.each(function(){
             if ($(this).parent().is(":visible")){
                if(check){ // check all
                    $(this).prop('checked', true);
                } else {
                    $(this).prop('checked', false);
                }
             }
            });

    }

  }
  };
return MultipleText;

});