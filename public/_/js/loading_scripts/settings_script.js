
$(document).ready(function(){
    $("#skillTable").html("<div id='loader'><i class='fa fa-spinner fa-spin'></i>Loading Skill RequirementTable now... </div>"); 
    $("#languageTable").html("<div id='loader'><i class='fa fa-spinner fa-spin'></i>Loading Language RequirementTable now... </div>"); 
    $("#educationTable").html("<div id='loader'><i class='fa fa-spinner fa-spin'></i>Loading Education Requirement Table now... </div>"); 
    $("#certificationTable").html("<div id='loader'><i class='fa fa-spinner fa-spin'></i>Loading Certification Requirement Table now... </div>"); 
    $("#experienceTable").load("/experiencetable",{i: new Date().getTime(), pk: <%=@user.id%>}); 
    document.getElementById('f1').scrollIntoView()
    $("#skillTable").load("/table",{i: new Date().getTime(), pk: <%=@user.id%>}); 
    //non singaporean and non-PR and active in seeking for job, show it!
    if (<%= @mynations %> != 157 && <%= @mynationtypes %> !=2 && <%= @userprofile.activeseeker %>){
       document.getElementById( 'spr_block' ).style.visibility = 'visible';
       if (<%= @userprofile.insingaporenow%> ){
        document.getElementById( 'insg_block' ).style.visibility = 'visible';
       }
    };
    if (<%= @mynations %> == 157 || <%= @mynationtypes %> ==2)  {
      document.getElementById( 'spr_block' ).style.visibility = 'hidden';
      document.getElementById( 'insg_block' ).style.visibility = 'hidden';
    } ;
    if (<%= @userprofile.travelfreq %> ==0){
      document.getElementById("f0").checked = true;
     }
    if (<%= @userprofile.travelfreq %> ==25){
      document.getElementById("f1").checked = true;
     }
    if (<%= @userprofile.travelfreq %> ==50){
      document.getElementById("f2").checked = true;
     }
    if (<%= @userprofile.travelfreq %> ==75){
      document.getElementById("f3").checked = true;
     }
    if (<%= @userprofile.travelfreq %> ==100){
      document.getElementById("f4").checked = true;
     }

    $('input[name="date-range-picker"]').daterangepicker({
      timePicker: false,
      showDropdowns: true,
      format: 'DD/MM/YYYY',
      }, function(start, end, label) {
        console.log(moment(start.format('YYYY-MM-DDTHH:mm:ss') + 'Z').utc().toISOString());
        from = moment(start.format('YYYY-MM-DDTHH:mm:ss') + 'Z').utc().toISOString();
        end =moment(end.format('YYYY-MM-DDTHH:mm:ss') + 'Z').utc().toISOString();
         $.ajax({
            url: '/update_inSG_Date',
            type: 'POST',
            data: {"insg_start": from, "insg_end": end, "pk" : <%=@userprofile.id %>},
            beforeSend : function(){
              $("#saving_date").html("<span id='saver'><i class='fa fa-spinner fa-spin'></i></span>");
            }, 
            success: function(response){
                        // newAlert("#alert_placeholder-tab", 'success', "Dates recorded");
                         $('#saver').fadeOut(1000, function() {
                          $(this).remove();
                         });
                      }
          });
    }); //date-range-picker

    $('#skr_careergoal').editable({
      tpl: "<input type='text' style='width: 700px';height:500px>",
      validate: function(value){
        if (!value) return 'This field is required';
        if(value.length >5000 ) {
          return 'You can only enter a maximum of 500 characters';
        }
      } //validate 
    }); //skr_careergoal

    $('#skilltable').editable({
      selector: 'a.skillrank',
      showbuttons: false
    }); //skilltable

    $('.Achievements').editable({
      selector: 'a.ec',
      tpl: "<input type='text' style='width: 700px';height:500px>",
      validate: function(value){
        if (!value) return 'This field is required';
        if(value.length >5000 ) {
          return 'You can only enter a maximum of 500 characters';
        }
      }, //validate 
      emptytext: '[Optional] Enter your achievement here',
      placeholder: '[Optional] Enter your achievement here'
    }); //.Achievements

    $('#languagetable').editable({
      selector: 'a.skr_lang_speakskill',
      showbuttons: false
    }); //languagetable

    $('#languagetable').editable({
      selector: 'a.skr_lang_writeskill',
      showbuttons: false
    }); //languagetable

    $('#expectedsalary').editable();
    $('#currentsalary').editable();
    $('#availability').editable();
    $('#skr_emp_currentjob').editable({disabled: true }); 

    $('#expectedsalary').editable('option', 'validate', function(v) {
      if(!v) return 'This is a required field!';
    }); //expectedsalary

    $('#currentsalary').editable('option', 'validate', function(v) {
        if (!isInt(v)){
          return "Invalid entry. Please re-enter";             
        }
    }); //currentsalary

    $('#expectedsalary').editable('option', 'validate', function(v) {
        if (!isInt(v)){
          return "Invalid entry. Please re-enter";             
        }
    }); //expectedsalary

    $('#industries').editable({
      source: function() {
                return (<%= @industries%>)
              },
      select2:  {
                 multiple: true,
                 dropdownAutoWidth : true,
                 placeholder: 'Select Industries', width: '500px'
                },
      allowClear: true,
      minimumInputLength: 3,
      mode: 'popup',
      showbuttons: 'bottom',
      placement: 'bottom',
      emptytext: 'Select your preferred industries'
    }); //industries

    $('#locations').editable({
      source: function() {
                return (<%= @locations %>)
              },
      select2:  {
                  multiple: true,
                  dropdownAutoWidth : true,
                  placeholder: 'Select locations', width: '500px'
                },
      allowClear: true,
      minimumInputLength: 3,
      mode: 'popup',
      showbuttons: 'bottom',
      placement: 'bottom',
      emptytext: 'Select your preferred Job locations'
    }); //locations

    $('#joblevel').editable({
      source: function() {
                return (<%= @levels%>)
              },
      select2: {
                 multiple: true,
                 dropdownAutoWidth : true,
                 placeholder: 'Select Job Levels', width: '500px'
                },
      allowClear: true,
      minimumInputLength: 3,
      mode: 'popup',
      showbuttons: 'bottom',
      placement: 'bottom',
      emptytext: 'Select your preferred Job levels'
    }); //joblevel

    $('#jobfunction').editable({
      source: function() {
                return (<%= @functions%>)
              },
      select2:  {
                  multiple: true,
                  dropdownAutoWidth : true,
                  placeholder: 'Select Job Functions', width: '500px'
                },
      allowClear: true,
      minimumInputLength: 3,
      mode: 'popup',
      showbuttons: 'bottom',
      placement: 'bottom',
      emptytext: 'Select your preferred Job functions'
    }); //jobfunction

    $('#skillsettingtable').dataTable({  
      "scrollY": 200,
      "ScrollX": true,
      "iDisplayLength": 10,
      "order": [[ 0, "desc" ]],
      "scrollCollapse": true,
      "jQueryUI": true,
      "aoColumns": [       
          null, null, null,
          { "bSortable": false }
        ]
    }); //skillsettingtable

    $('#languagesettingtable').dataTable({
      "scrollY": 200,
      "ScrollX": true,
      "iDisplayLength": 10,
      "order": [[ 0, "desc" ]],
      "scrollCollapse": true,
      "jQueryUI": true,
      "aoColumns": [       
          null, null, null,
          { "bSortable": false }
        ]
    }); //languagesettingtable

  }); //document ready


// ------------ POST LOADING START Loading the respective tables when user click on the tab.--------
  $('#languagetabclick').one("click", function() {
      $("#languageTable").load("/langtable",{i: new Date().getTime(), pk: <%=@user.id%>}); 
  }); //languagetabclick

  $('#edutabclick').one("click", function() {
      $("#educationTable").load("/edutable",{i: new Date().getTime(), pk: <%=@user.id%>}); 
  }); //edutabclick

  $('#certtabclick').one("click", function() {
      $("#certificationTable").load("/certtable",{i: new Date().getTime(), pk: <%=@user.id%>}); 
  }); //certtabclick
//-------------------------END OF POST LOADING ------------------------------------
  $("#activecheck").on('change', function(){
    $.ajax({
      url: '/updateactive',
      type: 'POST',
      data: {"activeseeker": this.checked, "pk" : <%=@user.id %>},
      beforeSend : function(){
        $("#saving").html("<span id='saver'><i class='fa fa-spinner fa-spin'></i></span>");
      }, 
      success: function(response){
        var data = JSON.parse(response);

        if (data.active){
           if (data.singaporepr != 2)
            {document.getElementById( 'spr_block' ).style.visibility = 'visible';}
           if (data.singaporepr != 2 && data.insingaporenow){
              document.getElementById( 'insg_block' ).style.visibility = 'visible';}          
        } else{
           document.getElementById( 'spr_block' ).style.visibility = 'hidden';
           document.getElementById( 'insg_block' ).style.visibility = 'hidden';
        }; //else
        $('#saver').fadeOut(1000, function() {
        $(this).remove();
       });
      } //success function
    }); //ajax
  }); //activecheck

  $("#insgcheck").on('change', function(){
    $.ajax({
      url: '/updatetmeprofile',
      type: 'POST',
      data: {"value": this.checked, "pk" : <%=@user.id %>, "name":"insingaporenow"},
      beforeSend : function(){
        $("#saving1").html("<div id='saver'><i class='fa fa-spinner fa-spin'></i></div>");
      },
      success: function(response){
        var data = JSON.parse(response);
        if (data.insingaporenow){
           document.getElementById( 'insg_block' ).style.visibility = 'visible';           
        } else{
           document.getElementById( 'insg_block' ).style.visibility = 'hidden';                    
        }; //else
            // $("#saving1").html("<div id='saver'>Saved...</div>");
            $('#saver').fadeOut(1000, function() {
             $(this).remove();
           });
      } //success functiom
    }); //ajax
  }); //insgcheck


  $("#parttimecheck").on('change', function(){
    $.ajax({
      url: '/updatetmeprofile',
      type: 'POST',
      data: {"value": this.checked, "pk" : <%=@user.id %>,"name":"parttime"},
      beforeSend : function(){
        $("#saving_parttime").html("<div id='saver_parttime'><i class='fa fa-spinner fa-spin'></i></div>");
      },
      success: function(response){
        var data = JSON.parse(response);
        if (data.parttime){
              newAlert("#alert_placeholder-tab", 'success', "You will be matched to any part time jobs");     
        } else {
              newAlert("#alert_placeholder-tab", 'success', "You will not be matched to part time jobs");  
        }                        
         $('#saver_parttime').fadeOut(1000, function() {
         $(this).remove();
       }); 
      } //success function
    }); //ajax
  }); //parttimecheck


  $("#fulltimecheck").on('change', function(){
      $.ajax({
        url: '/updatetmeprofile',
        type: 'POST',
        data: {"value": this.checked, "pk" : <%=@user.id %>, "name":"fulltime"},
        beforeSend : function(){
          $("#saving_fulltime").html("<div id='saver_fulltime'><i class='fa fa-spinner fa-spin'></i></div>");
        },
        success: function(response){
          var data = JSON.parse(response);
          if (data.fulltime){
               newAlert("#alert_placeholder-tab", 'success', "You will be matched to full time jobs");  
          } else {

                newAlert("#alert_placeholder-tab", 'success', "You will not be matched to full time jobs");    
          }                               
           $('#saver_fulltime').fadeOut(1000, function() {
           $(this).remove();
         });
        } //success function
      }); //ajax
    }); //fulltimecheck

  $("#shiftworkcheck").on('change', function(){
    $.ajax({
      url: '/updatetmeprofile',
      type: 'POST',
      data: {"value": this.checked, "pk" : <%=@user.id %>,  "name":"shiftwork"},
      beforeSend : function(){
        $("#saving_shift").html("<div id='saver_shift'><i class='fa fa-spinner fa-spin'></i></div>");
      },
      success: function(response){
        var data = JSON.parse(response);
        if (data.shiftwork){
             newAlert("#alert_placeholder-tab", 'success', "You will be matched to jobs requiring shift work");                                    
        } else {
             newAlert("#alert_placeholder-tab", 'success', "You will not be matched to jobs requiring shift work");  
        }
         $('#saver_shift').fadeOut(1000, function() {
         $(this).remove();
       });
      } //success function
    }); //ajax
  }); //shiftworkcheck

  $("#outofhourscheck").on('change', function(){
    $.ajax({
      url: '/updatetmeprofile',
      type: 'POST',
      data: {"value": this.checked, "pk" : <%=@user.id %>, "name":"outofhours"},
      beforeSend : function(){
        $("#saving_out").html("<span id='saver_out'><i class='fa fa-spinner fa-spin'></i></span>");
      },
      success: function(response){
        var data = JSON.parse(response);
        if (data.outofhours){
             newAlert("#alert_placeholder-tab", 'success', "You will be matched to jobs requiring you to work outside office hour");
         } else {
             newAlert("#alert_placeholder-tab", 'success', "You will not be matched to jobs requiring you to work outside office hour");  
         }                        
          $('#saver_out').fadeOut(1000, function() {
         $(this).remove();
       });
      } //success function
    }); //ajax
  }); // outofhourscheck

  $("#interncheck").on('change', function(){
      $.ajax({
        url: '/updatetmeprofile',
        type: 'POST',
        data: {"value": this.checked, "pk" : <%=@user.id %>, "name":"skr_intern"},
        beforeSend : function(){
          $("#saving_intern").html("<div id='saver_i'><div id='saver_fulltime'><i class='fa fa-spinner fa-spin'></i></div>");
        },
        success: function(response){
          var data = JSON.parse(response);                           
           $('#saver_i').fadeOut(1000, function() {
           $(this).remove();
         });
        } //success function
      }); //ajax
  }); // interncheck

  $("#contractorcheck").on('change', function(){
    $.ajax({
      url: '/updatetmeprofile',
      type: 'POST',
      data: {"value": this.checked, "pk" : <%=@user.id %>, "name":"skr_contractor"},
      beforeSend : function(){
        $("#saving_contractor").html("<div id='saver_c'><i class='fa fa-spinner fa-spin'></i></div>");
      },
      success: function(response){
        var data = JSON.parse(response);                           
         $('#saver_c').fadeOut(1000, function() {
         $(this).remove();
       });
      } //success function
    }); //ajax
  }); // contractorcheck

  function freqcheck(myRadio) {
      $.ajax({
        url: '/updatetmeprofile',
        type: 'POST',
        data: {"value": myRadio.value, "pk" : <%=@user.id %>, "name":"travelfreq"},
        beforeSend : function(){
          $("#saving_radio").html("<div id='saver_r'><i class='fa fa-spinner fa-spin'></i></div>");
        },
        success: function(response){
          // var data = JSON.parse(response);                           
           $('#saver_r').fadeOut(1000, function() {
              $(this).remove();
           });
        } //success function
      }); //ajax
  }; // freqcheck

  function isInt(value) {
    return !isNaN(value) &&
           parseInt(Number(value)) == value &&
           !isNaN(parseInt(value, 10));
  } //isInt

  function delskill(element,i){
    $.ajax({
            url: '/deleteskill',
            type: 'POST',
            data: {"pk" : i},
            success: function(response){
              var row=$(element).parents('tr')
              $('#skillsettingtable').dataTable().fnDeleteRow(row[0]);
              newAlert("#alert_placeholder-tab", 'success', "Skill deleted!");
            } //success
    }); //ajax
  } //delskill

  function delexp(element,i){
    $.ajax({
            url: '/deleteexp',
            type: 'POST',
            data: {"pk" : i},  //jobID
            success: function(response){
              var row=$(element).parents('tr')
              $('#experiencesettingtable').dataTable().fnDeleteRow(row[0]);
              newAlert("#alert_placeholder-tab", 'success', "Job Experience deleted!");
            } //success
    }); //ajax
  }//delexp

  function dellanguage(element,i){
    $.ajax({
            url: '/deletelanguage',
            type: 'POST',
            data: {"pk" : i, "userid": <%= @user.id %>},
            success: function(response){
              var row=$(element).parents('tr')
              $('#languagesettingtable').dataTable().fnDeleteRow(row[0]);
              newAlert("#alert_placeholder-tab", 'success', "Language deleted!");

            } //success
    }); //ajax
  }//dellanguage

  function deledu(element,i){
    $.ajax({
      url: '/deleteedu',
      type: 'POST',
      data: {"pk" : i, "userid": <%= @user.id %>},
      success: function(response){
        var row=$(element).parents('tr')
        $('#edusettingtable').dataTable().fnDeleteRow(row[0]);
        newAlert("#alert_placeholder-tab", 'success', "Education deleted!");
      } //success
    }); //ajax
  }//deledu

  function delcert(element,i){
    $.ajax({
            url: '/deletecert',
            type: 'POST',
            data: {"pk" : i, "userid": <%= @user.id %>},
            success: function(response){
              var row=$(element).parents('tr')
              $('#certsettingtable').dataTable().fnDeleteRow(row[0]);
              newAlert("#alert_placeholder-tab", 'success', "Certification deleted!");
            } //success
    }); //ajax
  }//delcert

  function newAlert (loc, type, message) {
      $(loc).append($("<div class='alert alert-block alert-" + type + " fade in' data-alert><p> " + message + " </p></div>"));
      $(".alert").delay(2000).fadeOut("slow", function () { $(this).remove(); });
  }//newAlert     

  $('#addexperiencemodal').on('hide.bs.modal', function(e) {   
      $("#experienceTable").load("/experiencetable",{i: new Date().getTime(), pk: <%= @user.id %>}); 
  }); //addexperiencemodal
  $('#editexperiencemodal').on('hide.bs.modal', function(e) {   
      $("#experienceTable").load("/experiencetable",{i: new Date().getTime(), pk: <%= @user.id %>}); 
  }); //editexperiencemodal
   $('#addskillmodal').on('hide.bs.modal', function(e) {   
      $("#skillTable").load("/table",{i: new Date().getTime(), pk: <%= @user.id %>}); 
  }); //addskillmodal
   $('#addedumodal').on('hide.bs.modal', function(e) {   
      $("#educationTable").load("/edutable",{i: new Date().getTime(), pk: <%= @user.id %>}); 
  }); //addedumodal
   $('#addcertmodal').on('hide.bs.modal', function(e) {   
      $("#certificationTable").load("/certtable",{i: new Date().getTime(), pk: <%= @user.id %>}); 
  }); //addcertmodal
   $('#addlanguagemodal').on('hide.bs.modal', function(e) {   
      $("#languageTable").load("/langtable",{i: new Date().getTime(), pk: <%= @user.id %>}); 
  }); //addlanguagemodal
