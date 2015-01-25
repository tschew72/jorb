

function revealcheck(a,i){
          $.ajax({
            url: '/updaterevealcoy',
            type: 'POST',
            data: {"job_companyreveal": a.checked, "pk" : i},
          });
          };        


function activateJob(jobid, coyid){
  var r = confirm("WARNING: This action is irreversible. Once activated, you will not be allowed to edit some of the fields.");
  if (r == true) {
      $.post( "/updatejob", {pk: jobid, name: "job_status", value: 2}, function( data ) {
        confirm("Job activated!");
        window.location.assign("/jobpostings?pk=" + coyid );
      });
  } 
  else {
      
  }
  return false; 
}; //activateJob

function cancelJob(jobid, coyid){
  var r = confirm("WARNING: This action is irreversible. Once cancelled, you will not be allowed to edit or re-activate again.");
  if (r == true) {
      $.post( "/updatejob", {pk: jobid, name: "job_status", value: 0}, function( data ) {
        confirm("Job cancelled!");
        window.location.assign("/jobpostings?pk=" + coyid );
      });
  } 
  else {
      
  }
  return false; 
}; //cancelJob
          
function kivJob(jobid, coyid){
  var r = confirm("You want to save this job posting for future editing.");
  if (r == true) {
      $.post( "/updatejob", {pk: jobid, name: "job_status", value: 4}, function( data ) {  //set to draft
        confirm("Job saved!");
        window.location.assign("/jobpostings?pk=" + coyid );
      });
  } 
  else {
      
  }
  return false; 
}; //kivJob

function delJob(jobid, coyid){
  var r = confirm("You want to delete this job posting. This action is irreversible");
  if (r == true) {
      $.post( "/delete_job", {id: jobid}, function( data ) { 
        confirm("Job deleted!");
        window.location.assign("/jobpostings?pk=" + coyid );
      });
  } 
  else {
      
  }
  return false; 
}; //delJob


  $('input[name="date-range-picker"]').daterangepicker({
    timePicker: false,
    singleDatePicker: true,
    showDropdowns: true,
    format: 'DD/MM/YYYY',
    }, 
    function(start, end, label) {
      console.log(moment(start.format('YYYY-MM-DDTHH:mm:ss') + 'Z').utc().toISOString());
    }
  );

$('input[name="date-range-picker"]').on('apply.daterangepicker', function(ev, picker) {
  from = moment(picker.startDate.format('YYYY-MM-DDTHH:mm:ss') + 'Z').utc().toISOString();
       $.ajax({
        url: '/updatejobclosingdate',
        type: 'POST',
        data: {"job_closed": from, "pk" : $(this).attr('data-id')},
        beforeSend : function(){
          // $("#saving_date").html("<div id='saver'><i class='fa fa-spinner fa-spin'></i></div>");
        },  
        success: function(response){
                     $('#saver').fadeOut(1000, function() {
                      $(this).remove();
                     });
                  }
      });
});




  $('#job_status').editable(
  { 
    success: function(response, newValue) {
      $("#tablespace").load("/activejobtable",{i: new Date().getTime()}); 
      // $(".tab-content").hide(); //Hide all content
      $("ul.nav-tabs  li").eq(1).addClass("active").show(); //Activate tab
      $("ul.nav-tabs  li").eq(2).removeClass("active"); //Activate tab 
      // $(".tab-content").eq(1).show(); //Show tab content
    } //success
  } 

    );




    // X-Editables Setup
      

      $('#job_contactname').editable(
      {
        emptytext: '--',
        validate: function(value) {
          if(value.length >120 ) {
            return 'You can only enter a maximum of 120 characters';
          }
        } //validate
      });

      $('#job_contactemail').editable(
      {
        emptytext: '--',
        validate: function(value) {
          var re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
          if (!re.test(value)) {
            return 'This is an invalid email address';  
          }
        } //validate 
      });

      $('#job_title_actual').editable(
      {
        emptytext: '--',
        validate: function(value) {
          if(value.length >500 ) {
            return 'You can only enter a maximum of 500 characters';
          }
        }
      });
        
      $('#job_contactphone').editable(
      {
        emptytext: '--',
        validate: function(value) {
          if(value.length >20 ) {
            return 'You have entered an invalid Phone number which is more than 20 digits';
          }
        }
      });

      $('#job_closed').editable(
      {
          emptytext: '--',
      });

      $('#job_title').editable({
        source: "/getjobtitle",
        emptytext: '--',
      });

      $('#job_location').editable({
        source: "/getcountries",
        emptytext: '--',
       });
          
      $('#job_industry  ').editable({
        source: "/getind",
        emptytext: '--',
       });

      $('#job_travel').editable({
        emptytext: '--',
       });

      $('#job_salarymin').editable({
        emptytext: '--',
        validate: function(value) {
            if (!isInt(value)){
              return "Invalid entry. Please re-enter";             
            }
          },
       });

      $('#job_salarymax').editable({
          emptytext: '--',
          validate: function(value) {
            if (!isInt(value)){
              return "Invalid entry. Please re-enter";             
            }
          },
       });

      $('#job_experience').editable(
      {
          emptytext: '--',
          validate: function(value) {
            if (!isInt(value)){
              return "Invalid entry. Please re-enter";             
            }
          },
      });

      $('#job_time').editable(
      {
          source: "/getworktime",
          emptytext: '--',
      });

      $('#job_function').editable({
        source: "/getfunction",
        emptytext: '--',
       });

      $('#skilltable').editable({
        selector: 'a.skillrank',
        showbuttons: false
      });

      $('#languagetable').editable({
        selector: 'a.job_lang_speakskill',
        showbuttons: false
      });

      $('#languagetable').editable({
        selector: 'a.job_lang_writeskill',
        showbuttons: false
      });

      $('#edutable').editable({
        selector: 'a.job_edu_pref',
        source: "/getpref",
        showbuttons: false
      });// edutable

      $('#certtable').editable({
        selector: 'a.job_cert_pref',
        source: "/getpref",
        showbuttons: false
      }); //certtable

      $('#job_edu_pref').editable({
        source: "/getpref",
        disabled: false,
        onblur: 'submit',
        showbuttons: false
      }); //job_edu_pref

      $('#job_cert_pref').editable({
        source: "/getpref",
        disabled: false,
        onblur: 'submit',
        showbuttons: false
      }); //job_cert_pref

    // X-Editable for Add Skill Modal 
      $('#skillcat').editable({
        source: "/getskillcat" ,
        onblur: 'submit',
        showbuttons: false,
        success: function(response, newValue) {

                 $.getJSON("/getskill", {"value": newValue}, function (result) {
                  $('#skillname').editable('option', 'source', result);   //somehow, all these 3 sentences must be in here.
                  $('#skillname').editable('setValue', null);             //else it will fail.
                  $('#skillname').editable('option', 'disabled', false);  //             
                  }).fail( function(d, textStatus, error) {
                      console.error("Error code: " + textStatus + ", error: "+error)

                  });
        }
      });

      $('#skillname').editable({
        disabled: true,
        onblur: 'submit',
        showbuttons: false,
        success: function(response, newValue)
        {
          $('#skillrank').editable('option', 'disabled', false);
        }
        });

      $('#skillrank').editable(
        {
        disabled: true,
        onblur: 'submit',
        showbuttons: false});

    // X-Editable for Add Language Modal
      $('#job_lang').editable({
        source: "/getlanguage",
        onblur: 'submit',
        showbuttons: false,
        success: function(response, newValue) {
           $('#job_lang_speakskill').editable('option', 'disabled', false);
        }
      }); //lang

      $('#job_lang_speakskill').editable({
        disabled: true,
        onblur: 'submit',
        showbuttons: false,
        success: function(response, newValue)
        {
          $('#job_lang_writeskill').editable('option', 'disabled', false);
        }
      }); //speakskill

      $('#job_lang_writeskill').editable(
        {
        disabled: true,
        onblur: 'submit',
        showbuttons: false});

    // X-Editable for Add Education Modal
      $('#job_edu_title').editable({
        source: "/getdegree",
        onblur: 'submit',
        showbuttons: false,
        success: function(response, newValue) {
           $('#job_edu_specialty').editable('option', 'disabled', false);
           if (newValue ==1 || newValue == 2 || newValue ==3) {
              $('#job_edu_honors').editable('option', 'disabled', true);
              $('#job_edu_specialty').editable('option', 'disabled', true);
           }else {
            $('#job_edu_honors').editable('option', 'disabled', false);
            $('#job_edu_specialty').editable('option', 'disabled', false);
           }
        }
      }); //job_edu_title

      $('#job_edu_specialty').editable({
        source: "/getspecialty",
        disabled: false,
        onblur: 'submit',
        showbuttons: false,
        success: function(response, newValue)
        {

        } //success
      }); //job_edu_specialty

      $('#job_edu_honors').editable({
          source: "/gethonors",
          disabled: false,
          onblur: 'submit',
          showbuttons: false,
          success: function(response, newValue)
          {
            $('#job_edu_pref').editable('option', 'disabled', false);
          }
      });//job_edu_honors

    // X-Editable for Add Certification Modal
        $('#job_cert_title').editable({
          source: "/getcert",
          onblur: 'submit',
          showbuttons: false,
          success: function(response, newValue) {
          } //success
        }); //job_cert_title

