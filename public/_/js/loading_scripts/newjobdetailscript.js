




function activateJob(jobid){
  var r = confirm("WARNING: This action is irreversible. Once activated, you will not be allowed to edit some of the fields.");
  if (r == true) {
      $.post( "/updatejob", {pk: jobid, name: "job_status", value: 2}, function( data ) {
        confirm("Job activated!");
        window.location.assign("/jobpostings");
      });
  } 
  else {
      
  }
  return false; 
}; //activateJob

function kivJob(jobid){
  var r = confirm("You want to save this job posting for future editing.");
  if (r == true) {
      $.post( "/updatejob", {pk: jobid, name: "job_status", value: 4}, function( data ) {  //set to draft
        confirm("Job saved!");
        window.location.assign("/jobpostings");
      });
  } 
  else {
      
  }
  return false; 
}; //activateJob



function revealcheck(a,i){
$.ajax({
  url: '/updaterevealcoy',
  type: 'POST',
  data: {"job_companyreveal": a.checked, "pk" : i},
});
};            



  $('input[name="date-range-picker"]').daterangepicker({
  timePicker: false,
  singleDatePicker: true,
  showDropdowns: true,
  format: 'DD/MM/YYYY',
  }, function(start, end, label) {
    console.log(moment(start.format('YYYY-MM-DDTHH:mm:ss') + 'Z').utc().toISOString());

    

  });

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


  $('#job_contactname').editable(
    {
      emptytext: '--',
    // placeholder: '[Optional] Enter your achievement here'
  });

  $('#job_status').editable(
     {success: function(response, newValue) {
        $("#tablespace").load("/activejobtable",{i: new Date().getTime()}); 
        // $(".tab-content").hide(); //Hide all content
        $("ul.nav-tabs  li").eq(1).addClass("active").show(); //Activate tab
        $("ul.nav-tabs  li").eq(2).removeClass("active"); //Activate tab 
        // $(".tab-content").eq(1).show(); //Show tab content
      }
          
        } //success

    );

 



  $('#job_contactemail').editable(
  {
    emptytext: '--',
  });

  $('#job_title_actual').editable(
  {
    emptytext: '--',
  });
    

      $('#job_contactphone').editable(
    {
      emptytext: '--',
    // placeholder: '[Optional] Enter your achievement here'
   });

      $('#job_closed').editable(
    {
      emptytext: '--',
    // placeholder: '[Optional] Enter your achievement here'
   });

