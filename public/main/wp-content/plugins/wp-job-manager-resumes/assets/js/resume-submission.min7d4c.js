jQuery(document).ready(function(){function a(){jQuery("fieldset.import-from-linkedin").remove(),IN.API.Profile("me").fields(["firstName","lastName","formattedName","headline","summary","specialties","associations","interests","pictureUrl","publicProfileUrl","emailAddress","location:(name)","dateOfBirth","threeCurrentPositions:(title,company,summary,startDate,endDate,isCurrent)","threePastPositions:(title,company,summary,startDate,endDate,isCurrent)","positions:(title,company,summary,startDate,endDate,isCurrent)","educations:(schoolName,degree,fieldOfStudy,startDate,endDate,activities,notes)","skills:(skill)","phoneNumbers","primaryTwitterAccount","memberUrlResources"]).result(function(a){var b=a.values[0];$form=jQuery("#submit-resume-form"),$form.find("input[name=candidate_name]").val(b.formattedName),$form.find("input[name=candidate_email]").val(b.emailAddress),$form.find("input[name=candidate_title]").val(b.headline),$form.find("input[name=candidate_location]").val(b.location.name),$form.find("textarea[name=resume_content]").val(b.summary),tinymce&&tinymce.get("resume_content").setContent(b.summary),jQuery(b.skills.values).each(function(a,b){$form.find("input[name=resume_skills]").val($form.find("input[name=resume_skills]").val()?$form.find("input[name=resume_skills]").val()+", "+b.skill.name:b.skill.name)}),jQuery(b.memberUrlResources.values).each(function(a,b){jQuery(".fieldset-links").find(".resume-manager-add-row").click(),jQuery(".fieldset-links").find("input[name^=link_name]").last().val(b.name),jQuery(".fieldset-links").find("input[name^=link_url]").last().val(b.url)}),jQuery(b.educations.values).each(function(a,b){var c=[],d=[];b.fieldOfStudy&&c.push(b.fieldOfStudy),b.degree&&c.push(b.degree),b.startDate&&d.push(b.startDate.year),b.endDate&&d.push(b.endDate.year),jQuery(".fieldset-candidate_education").find(".resume-manager-add-row").click(),jQuery(".fieldset-candidate_education").find("input[name^=candidate_education_location]").last().val(b.schoolName),jQuery(".fieldset-candidate_education").find("input[name^=candidate_education_qualification]").last().val(c.join(", ")),jQuery(".fieldset-candidate_education").find("input[name^=candidate_education_date]").last().val(d.join("-")),jQuery(".fieldset-candidate_education").find("textarea[name^=candidate_education_notes]").last().val(b.notes)}),jQuery(b.positions.values).each(function(a,b){var c=[];b.startDate&&c.push(b.startDate.year),b.endDate&&c.push(b.endDate.year),jQuery(".fieldset-candidate_experience").find(".resume-manager-add-row").click(),jQuery(".fieldset-candidate_experience").find("input[name^=candidate_experience_employer]").last().val(b.company.name),jQuery(".fieldset-candidate_experience").find("input[name^=candidate_experience_job_title]").last().val(b.title),jQuery(".fieldset-candidate_experience").find("input[name^=candidate_experience_date]").last().val(c.join("-")),jQuery(".fieldset-candidate_experience").find("textarea[name^=candidate_experience_notes]").last().val(b.summary)}),$form.trigger("linkedin_import",b)})}jQuery(".resume-manager-add-row").click(function(){return jQuery(this).before(jQuery(this).data("row")),!1}),jQuery("#submit-resume-form").on("click",".resume-manager-remove-row",function(){return jQuery(this).closest("div.resume-manager-data-row").remove(),!1}),jQuery(".job-manager-remove-uploaded-file").click(function(){return jQuery(this).closest(".job-manager-uploaded-file").remove(),!1}),jQuery(".fieldset-candidate_experience .field, .fieldset-candidate_education .field, .fieldset-links .field").sortable({items:".resume-manager-data-row",cursor:"move",axis:"y",scrollSensitivity:40,forcePlaceholderSize:!0,helper:"clone",opacity:.65});var b=!1;jQuery("form#resume_preview").size()&&(b=!0),jQuery("form").on("change","input",function(){b=!0}),jQuery("form").submit(function(){return b=!1,!0}),jQuery(window).bind("beforeunload",function(){return b?resume_manager_resume_submission.i18n_navigate:void 0}),jQuery("input.import-from-linkedin").click(function(){return IN.User.isAuthorized()?a():(IN.Event.on(IN,"auth",a),IN.UI.Authorize().place()),!1})});