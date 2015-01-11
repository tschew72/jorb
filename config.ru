require 'sinatra'
require 'bundler'
require 'warden'
require './model'
require 'json'
require 'newrelic_rpm'
require 'digest/sha1'
require 'dm-chunked_query'


# Unicorn self-process killer
require 'unicorn/worker_killer'

# Max requests per worker
use Unicorn::WorkerKiller::MaxRequests, 3072, 4096

# Max memory size (RSS) per worker
use Unicorn::WorkerKiller::Oom, (192*(1024**2)), (256*(1024**2))

class SinatraWardenExample < Sinatra::Application

use Rack::Session::Cookie, :key => 'rack.session', :expire_after => 365*24*60*60
 


use Warden::Manager do |config|

    # Tell Warden how to save our User info into a session.
    # Sessions can only take strings, not Ruby code, we'll store
    # the User's `id`
    config.serialize_into_session{|user| user.id }
    # Now tell Warden how to take what we've stored in the session
    # and get a User from that information..
    config.serialize_from_session{|id| User.get(id) }

    config.scope_defaults :default,
      # "strategies" is an array of named methods with which to
      # attempt authentication. We have to define this later.
      strategies: [:password],
      # The action is a route to send the user to when
      # warden.authenticate! returns a false answer. We'll show
      # this route below.
      action: 'auth/unauthenticated'
    # When a user tries to log in and cannot, this specifies the
    # app to send the user to.
    config.failure_app = self
  end

  Warden::Manager.before_failure do |env,opts|
    env['REQUEST_METHOD'] = 'POST'
  end

  Warden::Strategies.add(:password) do
    def valid?
      params['user'] && params['user']['username'] && params['user']['password']
    end

    def authenticate!
      user = User.first(username: params['user']['username'])

      if user.nil?
        fail!("The username you entered does not exist.")
      elsif user.authenticate(params['user']['password'])
        success!(user)
      else
        fail!("Could not log in")
      end
    end
  end



helpers do

  def current_user
     !session[:uid].nil?
  end

end
 

 before do
   #pass if request.path_info =~ /^\/auth\//
   #Not sure why if I put this redirect statement, everything won't work.
   #redirect to('/auth/twitter') unless current_user
 
 end

# Main Page to welcome users
get '/' do
   erb :"main/index", :layout => :'main/layout1'
end
 
#===============================Job Seeker Section================================

# Analytics page for Job Seekers
get '/edge' do
  # If user comes in directly here, if not authenticated, throw them to /auth/login
  redirect '/auth/login' unless env['warden'].authenticated?
  @user = env['warden'].user
  if @user.usertype == 2
  redirect '/auth/unauthorized'
  end
  @userprofile = @user.tme_skr_main
  @userme = @user.firstname
  @emailme = @user.email
  @usermatchjoblist = @userprofile.matched_jobs
  erb :"dash/index", :layout => :'dash/layout1'
end #edge


# Ajax call for generating the job match table in index.erb
post '/jobmatchtable' do 
  @user = env['warden'].user
  @skrid = @user.id.to_s
  cmd1 = "SELECT * FROM skrmatch(" + @skrid + ")"
  @jobmatches=repository(:default).adapter.select(cmd1)
  erb :jobmatchtable, :layout => false
end #jobmatchtable

# Ajax call for generating the job match detail table in index.erb
post '/jobmatchdetail' do 
  @user = env['warden'].user
  @jobid = params["pk"].to_s
  @skrid = params["skrid"].to_s  #also need to give this to j_mycv in matchdetail.erb
  cmd2 = "select * from jobmatch_skrdetail_pers_func("+ @skrid +")"
  @skrdetail_pers=repository(:default).adapter.select(cmd2)  
  cmd3 = "select * from jobmatch_skrdetail(" + @jobid + "," + @skrid +")"
  @skrdetail=repository(:default).adapter.select(cmd3)
  erb :jobmatchdetail, :layout => false
end #jobmatchdetail

# Online CV Page for Job Seeker
get '/mycv' do
  redirect '/auth/login' unless env['warden'].authenticated?
  @user = env['warden'].user
  if @user.usertype == 2
    redirect '/auth/unauthorized'
  end
  @userprofile = @user.tme_skr_main
  @userme = @user.firstname
  @cmaster = TmeListCountry
  @uni = TmeListUniversity
  @degree = TmeListDegree
  @allskills =   @userprofile.skill_summaries.all(:order => [ :skillrank.desc ], :limit => 10, :status.gt =>0)
  @allachievements = @userprofile.tme_skr_achieve.all
  @alledu =   @userprofile.tme_skr_edu.all
  @alljobs = @userprofile.tme_skr_emp.all
  @ssmaster = SkillSource  #master skill source for cross referencing
  @mynations=@userprofile.tme_skr_nation.first(:tme_skr_main_id=>@userprofile.id).skr_nation
  @mynationtypes=@userprofile.tme_skr_nation.first(:tme_skr_main_id=>@userprofile.id).skr_nation_type
  erb :"dash/mycv", :layout => :'dash/layout1'
end #mycv

# Job Seeker Profile Page
get '/profile' do
  redirect '/auth/login' unless env['warden'].authenticated?
  @user = env['warden'].user
  if @user.usertype == 2
    redirect '/auth/unauthorized'
  end
  @userprofile = @user.tme_skr_main
  @userme = @user.firstname
  sc = @userprofile.tme_skr_socialmedia.all
  sc.each do |x|
    if x.skr_socialmediacat == 1
      @facebook = x.skr_socialmediaurl
    end
    if x.skr_socialmediacat == 2
      @github = x.skr_socialmediaurl
    end
    if x.skr_socialmediacat == 3
      @linkedin = x.skr_socialmediaurl
    end
    if x.skr_socialmediacat == 4
      @twitter = x.skr_socialmediaurl
    end
    if x.skr_socialmediacat == 5
      @google = x.skr_socialmediaurl
    end
  end # sc.each end
  @mynations=@userprofile.tme_skr_nation.first(:tme_skr_main_id=>@userprofile.id).skr_nation
  @mynationtypes=@userprofile.tme_skr_nation.first(:tme_skr_main_id=>@userprofile.id).skr_nation_type

  @cmaster = TmeListCountry.all
  ctemp = []
  @cmaster.each do |x|
     ctemp << {value: x.country_id, text: "#{x.country}"}
  end
  @countries = ctemp.to_json
  erb :"dash/profile", :layout => :'dash/layout1'
end

post '/updateachievement' do
  achievement = TmeSkrAchieve.get(params["pk"])
  result = params["value"]
  achievement.update(:achievement => result)
  return 200
end


post '/updateskillrank' do
  myskill = SkillSummary.get(params["pk"])
  myskill.update(:skillrank => params["value"])
  myskill.update(:status =>1)
  return 200
end

post '/updateLangSkill' do
  mylang = TmeSkrLanguage.get(params["pk"])
  mylang.update(eval(":#{params['name']}") => params["value"])
  mylang.update(:skr_status =>1)
  return 200
end


#===============================Job Seeker Career Profile Section================================
get '/settings' do

  redirect '/auth/login' unless env['warden'].authenticated?

  @user = env['warden'].user
  if @user.usertype == 2
  redirect '/auth/unauthorized'
  end
  @userprofile = @user.tme_skr_main
  @userme = @user.firstname
  #@careerscore = @userprofile.skrscore.skrscore_total
  @allskills =   @userprofile.skill_summaries.all
  @alllanguages = @userprofile.tme_skr_language.all
  #@allachievements = @userprofile.tme_skr_achieve.all
  @myachievements = @userprofile.tme_skr_achieve.first(:tme_skr_main_id=>@userprofile.id)
  @ssmaster = SkillSource  #master skill source for cross referencing
  @mynations=@userprofile.tme_skr_nation.first(:tme_skr_main_id=>@userprofile.id).skr_nation
  @mynationtypes=@userprofile.tme_skr_nation.first(:tme_skr_main_id=>@userprofile.id).skr_nation_type

  #Preferred Level
  plevel = @userprofile.tme_skr_preftitle.all
  @pref_level=""
  plevel.each do |i|
  @pref_level = @pref_level + plevel.get(i).skr_preftitle.to_s + ","
  end

  #Preferred Job Functions
  pfunc = @userprofile.tme_skr_preffunc.all
  @pref_func=""
  pfunc.each do |i|
  @pref_func = @pref_func + pfunc.get(i).skr_preffunc.to_s + ","
  end

  #Preferred Industries
  pind = @userprofile.tme_skr_prefind.all
  @pref_ind=""
  pind.each do |i|
    @pref_ind  = @pref_ind + pind.get(i).skr_prefind.to_s + ","
  end

  #Preferred Locations
  pc= @userprofile.tme_skr_prefloc.all
  @pref_loc=""
  pc.each do |i|
    @pref_loc = @pref_loc + pc.get(i).skr_prefloc.to_s + ","
  end

  @indmaster = TmeListIndustry.all   #Industry Master       #Hardcode to HTML. Remove from Database.
  indtemp = []
     @indmaster.each do |x|
     indtemp << {id: x.industry_id, text: "#{x.industry}"}
  end
  @industries = indtemp.to_json

  @locmaster = TmeListCountry.all
  loctemp = []
  @locmaster.each do |x|
     loctemp << {id: x.country_id, text: "#{x.country}"}
  end
  @locations = loctemp.to_json

  @levelmaster = TmeListTitle.all
  leveltemp = []
  @levelmaster.each do |x|
     leveltemp << {id: x.title_id, text: "#{x.title}"}
  end
  @levels = leveltemp.to_json

  @functionmaster = TmeListFunction.all
  functemp = []
  @functionmaster.each do |x|
     functemp << {id: x.function_id, text: "#{x.function}"}
  end
  @functions = functemp.to_json

  @scmaster = SkillCategory.all   #Skill Category Master
  cattemp = []
    @scmaster.each do |x|
    cattemp << {value: x.id, text: "#{x.categoryname}"}
  end
  @skillcat= cattemp.to_json

  @lmaster = TmeListLanguage.all
  ltemp = []
     @lmaster.each do |x|
     ltemp << {value: x.language_id, text: "#{x.language}"}
  end

  @langlist= ltemp.to_json
  @sr = SkillRank.all
  erb :"dash/settings", :layout => :'dash/layout1'
end

#=============================== Job Seeker : TmeSeekerMain Section================================
post '/updateprofile' do
  userdata = User.get(params["pk"])
  userdata.update(eval(":#{params['name']}") => params["value"])
  if params['name'] == "email"
    userdata.update(:username => params["value"])
  end
  return 200
end #updateprofile

post '/updatetmeprofile' do
  userdata = TmeSkrMain.get(params["pk"])
  userdata.update(eval(":#{params['name']}") => params["value"])
  {eval(":#{params['name']}") => eval("userdata.#{params['name']}")}.to_json 
end #updatetmeprofile

post '/updatenationality' do
  userdata = TmeSkrMain.get(params["pk"])
  mynations=userdata.tme_skr_nation.first(:tme_skr_main_id=>userdata.id)
  mynations.update(:skr_nation => params["value"])
  return 200
end #updatenationality

post '/updateactive' do
  userdata = User.get(params["pk"]).tme_skr_main
  mynationtypes=userdata.tme_skr_nation.first(:tme_skr_main_id=>userdata.id).skr_nation_type
  userdata.update(:activeseeker => params['activeseeker'])
  { :active => userdata.activeseeker, :insingaporenow => userdata.insingaporenow, :singaporepr => mynationtypes}.to_json
end #updateactive

post '/updatedob' do
  userdata = TmeSkrMain.get(params["pk"])
  str=params["dob"]
  date=Date.parse str
  userdata.update(:dob => date)
  return 200
end #updatedob

post '/update_inSG_Date' do 
  userdata = User.get(params["pk"]).tme_skr_main
  str1=params["insg_start"]
  date1=Date.parse str1
  str2=params["insg_end"]
  date2=Date.parse str2
  userdata.update(:insg_start=> date1)
  userdata.update(:insg_end => date2)
  return 200
end #update_inSG_Date

post '/updatespr' do
  #userdata = User.get(params["pk"]).tme_skr_main
  userdata = TmeSkrMain.get(params["pk"])
  if params["singaporepr"] =="true"
    ntype=2
  else ntype=1 
  end
  type=userdata.tme_skr_nation.first(:tme_skr_main_id=>userdata.id)
  type.update(:skr_nation_type => ntype)
  return 200
end #updatespr

post '/updateskill' do
  userprofile = env['warden'].user
  myskill = userprofile.tme_skr_main.skill_summaries.get(params["pk"])
  myskill.update(:skillid => params["value"])
  myskill.update(:status =>1)
  return 200
end

post '/newskill' do
  u = User.get(params["pk"])
  userprofile = u.tme_skr_main 
  if params["skillid"] == nil || params["skillrank"] == nil
    {:errors => "All fields are required!" }.to_json
  else
    newskill = SkillSummary.first_or_create({:skillid => params["skillid"],:tme_skr_main_id => userprofile.id}).update(:skillrank => params["skillrank"], :tme_skr_main_id => userprofile.id, :status =>2)
    {:responsemsg => "New skill added!" }.to_json
  end
end #newskill

post '/newlanguage' do
  u = User.get(params["pk"])
  userprofile = u.tme_skr_main
  if params["skr_lang"] == nil || params["skr_lang_speakskill"] == nil || params["skr_lang_writeskill"] == nil
    {:errors => "All fields are required!" }.to_json
  else
    newlanguage = TmeSkrLanguage.first_or_create({:skr_lang => params["skr_lang"], :tme_skr_main_id => userprofile.id}).update(:skr_lang_speakskill => params["skr_lang_speakskill"], :skr_lang_writeskill => params["skr_lang_writeskill"], :tme_skr_main_id => userprofile.id, :skr_status =>2)
        {:responsemsg => "New language added!" }.to_json
  end
end #newlanguage


post '/newedu' do
  u = User.get(params["pk"])
  userprofile = u.tme_skr_main

  if params["skr_unistart"] != nil
    startdate = Date.parse(params["skr_unistart"])
  else
    return {:errors => "Please enter the start date" }.to_json
  end

  if params["skr_uniend"]!= nil
    enddate = Date.parse(params["skr_uniend"])
  else
    return {:errors => "Please enter the end date" }.to_json
  end
 
  enddate = Date.parse(params["skr_uniend"])
  if enddate < startdate
    return {:errors => "End date cannot be earlier than Start date!" }.to_json
  end
  if startdate > Date.today
    return {:errors => "Invalid start date!" }.to_json
  end

  if params["skr_unititle"] == nil
    {:errors => "All fields are required!" }.to_json
  end
  if  params["skr_unititle"].to_i < 4 &&  params["skr_unititle"] != nil
    if params["skr_unistart"] == nil  || params["skr_uniend"] == nil
      {:errors => "All fields are required!" }.to_json
    else
      newedu = TmeSkrEdu.first_or_create({:skr_unititle => params["skr_unititle"],  :tme_skr_main_id => userprofile.id}).update(:skr_unititle => params["skr_unititle"], :skr_unistart => params["skr_unistart"], :skr_uniend => params["skr_uniend"], :tme_skr_main_id => userprofile.id, :skr_edustatus =>2)
      {:responsemsg => "New Education Added!" }.to_json
    end
  else
    if params["skr_unititle"] == nil || params["skr_unistart"] == nil  || params["skr_uniend"] == nil || params["skr_honours"] == nil || params["skr_specialty"] == nil || params["skr_university"] == nil
      {:errors => "All fields are required!" }.to_json
    else
     newedu = TmeSkrEdu.first_or_create({:skr_unititle => params["skr_unititle"],  :tme_skr_main_id => userprofile.id}).update(:skr_unititle => params["skr_unititle"], :skr_university => params["skr_university"], :skr_specialty => params["skr_specialty"], :skr_honours => params["skr_honours"], :skr_unistart => params["skr_unistart"], :skr_uniend => params["skr_uniend"], :tme_skr_main_id => userprofile.id, :skr_edustatus =>2)
      {:responsemsg => "New Education Added!" }.to_json
    end
  end
end #newedu

post '/newcert' do
  u = User.get(params["pk"])
  userprofile = u.tme_skr_main

  if params["skr_datecertified"] != nil
    startdate = Date.parse(params["skr_datecertified"])
  else
    return {:errors => "Please enter date of certification" }.to_json

  end
  if params["skr_certexpiry"] != nil
    enddate = Date.parse(params["skr_certexpiry"])
    if enddate < startdate
      puts "Invalid expiry date!"
      return {:errors => "Invalid expiry date!" }.to_json
    end
  end
  if startdate > Date.today
    puts "Invalid date of Certification!"
    return {:errors => "Invalid date of Certification!" }.to_json
  end

  if params["skr_certtitle"] == nil || params["skr_datecertified"] == nil
    {:errors => "Certificate Name and Date of Certification fields are required!" }.to_json
  else
    newcert = TmeSkrCert.first_or_create({:skr_certtitle => params["skr_certtitle"], :tme_skr_main_id => userprofile.id}).update(:skr_certtitle => params["skr_certtitle"], :skr_datecertified => params["skr_datecertified"], :skr_certlicense => params["skr_certlicense"], :skr_certexpiry => params["skr_certexpiry"], :tme_skr_main_id => userprofile.id, :skr_certstatus =>2)
    {:responsemsg => "New Certificate Added!" }.to_json
  end
end #newcert

post '/newexperience' do
  u = User.get(params["pk"])
  userprofile = u.tme_skr_main
  if params["skr_emp_start"] != nil
    startdate = Date.parse(params["skr_emp_start"])
  else
    return {:errors => "Please enter employment start date" }.to_json
  end

  if params["skr_emp_currentjob"] != "true"
    if params["skr_emp_end"] != nil
      enddate = Date.parse(params["skr_emp_end"])
    else
        return {:errors => "Please enter employment end date" }.to_json
    end
    if enddate < startdate
      puts "End date before start date!"
      return {:errors => "End date cannot be earlier than Start date!" }.to_json
    end
  end
 
  if startdate > Date.today
    puts "Start date cannot be more than today's date"
    return {:errors => "Invalid start date!" }.to_json
  end

  if params["skr_emp_currentjob"] != "true"
    if params["skr_emp_company"] == nil || params["skr_emp_industry"] == nil || params["skr_emp_start"] == nil || params["skr_emp_end"] == nil || params["skr_emp_location"] == nil || params["skr_emp_function"] == nil || params["skr_emp_title"] == nil || params["skr_emp_actualtitle"] == nil || params["skr_emp_desc"] == nil
      {:errors => "All fields are required!" }.to_json
    else
      newexp = TmeSkrEmp.create(:skr_emp_company => params["skr_emp_company"], :tme_skr_main_id => userprofile.id, :skr_emp_industry => params["skr_emp_industry"], :skr_emp_start => params["skr_emp_start"], :skr_emp_end => params["skr_emp_end"], :skr_emp_location => params["skr_emp_location"], :skr_emp_function => params["skr_emp_function"], :skr_emp_title => params["skr_emp_title"], :skr_emp_actualtitle => params["skr_emp_actualtitle"], :skr_emp_desc => params["skr_emp_desc"], :tme_skr_main_id => userprofile.id, :skr_emp_currentjob => params["skr_emp_currentjob"], :skr_empstatus =>2)
      {:responsemsg => "New Job Experience Added!" }.to_json
    end
  else
    if params["skr_emp_company"] == nil || params["skr_emp_industry"] == nil || params["skr_emp_start"] == nil || params["skr_emp_location"] == nil || params["skr_emp_function"] == nil || params["skr_emp_title"] == nil || params["skr_emp_actualtitle"] == nil || params["skr_emp_desc"] == nil
      {:errors => "All fields are required!" }.to_json
    else
      newexp = TmeSkrEmp.create(:skr_emp_company => params["skr_emp_company"], :tme_skr_main_id => userprofile.id, :skr_emp_industry => params["skr_emp_industry"], :skr_emp_start => params["skr_emp_start"], :skr_emp_location => params["skr_emp_location"], :skr_emp_function => params["skr_emp_function"], :skr_emp_title => params["skr_emp_title"], :skr_emp_actualtitle => params["skr_emp_actualtitle"], :skr_emp_desc => params["skr_emp_desc"], :tme_skr_main_id => userprofile.id, :skr_emp_currentjob => params["skr_emp_currentjob"], :skr_empstatus =>2)
      {:responsemsg => "New Job Experience Added!" }.to_json
    end
  end
end #newexperience


post '/newpassword' do
  userid = params["pk"]
  password1 = params["password-1"]
  password2 = params["password-2"]
  if password1 == "" || password2 == ""
    return {:errors => "All fields are required" }.to_json
  end
  if password2 != password1
    return {:errors => "The password entered does not match. Please try again" }.to_json
  else
    User.get(userid).update(:password => password1)
    {:responsemsg => "Password updated!" }.to_json
  end
end #newpassword

post '/editexperience' do
  userprofile = TmeSkrMain.get(params["pk"])

  if params["skr_emp_start"] != nil
    startdate = Date.parse(params["skr_emp_start"])
  else
    return {:errors => "Please enter employment start date" }.to_json
  end

  if params["skr_emp_currentjob"] != "true"
    if params["skr_emp_end"] != nil
      enddate = Date.parse(params["skr_emp_end"])
    else
      return {:errors => "Please enter employment end date" }.to_json
    end
 
    if enddate < startdate
      puts "End date before start date!"
      return {:errors => "End date cannot be earlier than Start date!" }.to_json
    end
  end

  if startdate > Date.today
    puts "Start date cannot be more than today's date"
    return {:errors => "Invalid start date!" }.to_json

  end

  if params["skr_emp_currentjob"] != "true"
    if params["skr_emp_company"] == nil || params["skr_emp_industry"] == nil || params["skr_emp_start"] == nil || params["skr_emp_end"] == nil || params["skr_emp_location"] == nil || params["skr_emp_function"] == nil || params["skr_emp_title"] == nil || params["skr_emp_actualtitle"] == nil || params["skr_emp_desc"] == nil
      {:errors => "All fields are required!!" }.to_json
    else
    
      newexp = TmeSkrEmp.get(params["jobid"]).update(:skr_emp_company => params["skr_emp_company"], :skr_emp_industry => params["skr_emp_industry"], :skr_emp_start => params["skr_emp_start"], :skr_emp_end => params["skr_emp_end"], :skr_emp_location => params["skr_emp_location"], :skr_emp_function => params["skr_emp_function"], :skr_emp_title => params["skr_emp_title"], :skr_emp_actualtitle => params["skr_emp_actualtitle"], :skr_emp_desc => params["skr_emp_desc"], :tme_skr_main_id => userprofile.id, :skr_emp_currentjob => params["skr_emp_currentjob"], :skr_empstatus =>2)
      {:responsemsg => "New Job Experience Added!!" }.to_json
    end
  else
    if params["skr_emp_company"] == nil || params["skr_emp_industry"] == nil || params["skr_emp_start"] == nil ||  params["skr_emp_location"] == nil || params["skr_emp_function"] == nil || params["skr_emp_title"] == nil || params["skr_emp_actualtitle"] == nil || params["skr_emp_desc"] == nil
      {:errors => "All fields are required!" }.to_json
    else
      newexp = TmeSkrEmp.get(params["jobid"]).update(:skr_emp_company => params["skr_emp_company"], :skr_emp_industry => params["skr_emp_industry"], :skr_emp_start => params["skr_emp_start"], :skr_emp_end => params["skr_emp_end"], :skr_emp_location => params["skr_emp_location"], :skr_emp_function => params["skr_emp_function"], :skr_emp_title => params["skr_emp_title"], :skr_emp_actualtitle => params["skr_emp_actualtitle"], :skr_emp_desc => params["skr_emp_desc"], :tme_skr_main_id => userprofile.id, :skr_emp_currentjob => params["skr_emp_currentjob"], :skr_empstatus =>2)
      {:responsemsg => "New Job Experience Added!" }.to_json
    end
  end
end #editexperience

#===============================Recruiter Section================================

# Analytics page for Recruiters
get '/hrm' do 
  redirect '/auth/login' unless env['warden'].authenticated?
  @user = env['warden'].user
  if @user.usertype == 1
    redirect '/auth/unauthorized'
  end
  @userprofile = @user.tme_skr_main
  @userme = @user.firstname
  emailme = @user.email
  mycoy =@user.tme_company_main
  @usermatchjoblist = mycoy.tme_job_main
  @mycoy = @user.tme_company_main
  @joblist = @mycoy.tme_job_main
  erb :hrm, :layout => :'dash/layout2'
end

post '/top5matchestable' do 
  @user = env['warden'].user
  @jobid = params["pk"]
  cmd1 = "SELECT * FROM jobmatch(" + @jobid + ")"
  @top5matches=repository(:default).adapter.select(cmd1)
  erb :top5matchestable, :layout => false
end

post '/matchdetail' do 
  @user = env['warden'].user
  @jobid = params["pk"].to_s
  @skrid = params["skrid"].to_s  #also need to give this to j_mycv in matchdetail.erb
  cmd2 = "select * from jobmatch_skrdetail_pers_func("+ @skrid +")"
  @skrdetail_pers=repository(:default).adapter.select(cmd2)  
  cmd3 = "select * from jobmatch_skrdetail(" + @jobid + "," + @skrid +")"
  @skrdetail=repository(:default).adapter.select(cmd3)
  erb :matchdetail, :layout => false
end

get '/jobpostings' do
  redirect '/auth/login' unless env['warden'].authenticated?
  @user = env['warden'].user
  if @user.usertype == 1
    redirect '/auth/unauthorized'
  end
  @userprofile = @user.tme_skr_main
  @userme = @user.firstname
  @mycoy = @user.tme_company_main
  @joblisting = @mycoy.tme_job_main.all
  erb :"dash/jobpostings", :layout => :'dash/layout2'
end


post '/updatecompanyprofile' do
  coydata = TmeCompanyMain.get(params["pk"])
  if params["name"] == "company_promo"
    if params["value"].length >10000
      { :status => "error", :msg => "Maximum of 10000 characters is allowed"}.to_json
    else
      coydata.update(eval(":#{params['name']}") => params["value"])
      { :status => "success", :msg => "Saved!"}.to_json
    end
  elsif params["name"] == "company_intro"
    if params["value"].length >50000
      { :status => "error", :msg => "Maximum of 50000 characters is allowed"}.to_json
    else
      coydata.update(eval(":#{params['name']}") => params["value"])
      { :status => "success", :msg => "Saved!"}.to_json
    end
  else 
    coydata.update(eval(":#{params['name']}") => params["value"])
    { :status => "success", :msg => "Saved!"}.to_json
  end
end

post '/updatecjoblisting' do
  coydata = TmeCompanyMain.get(params["pk"])
  coydata.update(eval(":#{params['name']}") => params["value"])
  return 200
end

post '/updateagent' do
  coydata = TmeCompanyMain.get(params["pk"])
  coydata.update(:company_isagent => params["isagent"])
  return 200
end

post '/updatecoyuser' do  #used in coyuserdetail.erb
  user = User.get(params["pk"])
  user.update(eval(":#{params['name']}") => params["value"])
  return 200
end





#===============================Admin Section================================
get '/admin' do
  @user = User.get(1)
  @userprofile = @user.tme_skr_main
  erb :"dash/admin", :layout => :'dash/layout3'
end

post '/admin_seekertable' do
    @allusers = User.all
    erb :admin_seekertable, :layout => false
end

post '/admin_editseekerprofile' do
  userid = params["pk"]
  @user = User.get(userid)
  @userprofile = @user.tme_skr_main
  #@userme = @user.firstname
  sc = @userprofile.tme_skr_socialmedia.all
  sc.each do |x|
    if x.skr_socialmediacat == 1
      @facebook = x.skr_socialmediaurl
    end
    if x.skr_socialmediacat == 2
      @github = x.skr_socialmediaurl
    end
    if x.skr_socialmediacat == 3
      @linkedin = x.skr_socialmediaurl
    end
    if x.skr_socialmediacat == 4
      @twitter = x.skr_socialmediaurl
    end
    if x.skr_socialmediacat == 5
      @google = x.skr_socialmediaurl
    end
  end

  @mynations=@userprofile.tme_skr_nation.first(:tme_skr_main_id=>@userprofile.id).skr_nation
  @mynationtypes=@userprofile.tme_skr_nation.first(:tme_skr_main_id=>@userprofile.id).skr_nation_type

  @cmaster = TmeListCountry.all
  ctemp = []
     @cmaster.each do |x|
     ctemp << {value: x.country_id, text: "#{x.country}"}
  end
  @countries = ctemp.to_json
  erb :"dash/admin_newseeker", :layout => false
end

post '/admin_editseekercareer' do
  userid = params["pk"]
  @user = User.get(userid)
  @userprofile = @user.tme_skr_main
  @userme = @user.firstname

  @allskills =   @userprofile.skill_summaries.all
  @alllanguages = @userprofile.tme_skr_language.all
  @myachievements = @userprofile.tme_skr_achieve.first(:tme_skr_main_id=>@userprofile.id)
  @ssmaster = SkillSource  #master skill source for cross referencing
  @mynations=@userprofile.tme_skr_nation.first(:tme_skr_main_id=>@userprofile.id).skr_nation
  @mynationtypes=@userprofile.tme_skr_nation.first(:tme_skr_main_id=>@userprofile.id).skr_nation_type

  #Preferred Level
  plevel = @userprofile.tme_skr_preftitle.all
  @pref_level=""
  plevel.each do |i|
  @pref_level = @pref_level + plevel.get(i).skr_preftitle.to_s + ","
  end

  #Preferred Job Functions
  pfunc = @userprofile.tme_skr_preffunc.all
  @pref_func=""
  pfunc.each do |i|
  @pref_func = @pref_func + pfunc.get(i).skr_preffunc.to_s + ","
  end

  #Preferred Industries
  pind = @userprofile.tme_skr_prefind.all
  @pref_ind=""
  pind.each do |i|
    @pref_ind  = @pref_ind + pind.get(i).skr_prefind.to_s + ","
  end

  #Preferred Locations
  pc= @userprofile.tme_skr_prefloc.all
  @pref_loc=""
  pc.each do |i|
    @pref_loc = @pref_loc + pc.get(i).skr_prefloc.to_s + ","
  end

  @indmaster = TmeListIndustry.all 
  indtemp = []
     @indmaster.each do |x|
     indtemp << {id: x.industry_id, text: "#{x.industry}"}
  end
  @industries = indtemp.to_json

  @locmaster = TmeListCountry.all
  loctemp = []
  @locmaster.each do |x|
     loctemp << {id: x.country_id, text: "#{x.country}"}
  end
  @locations = loctemp.to_json

  @levelmaster = TmeListTitle.all
  leveltemp = []
  @levelmaster.each do |x|
     leveltemp << {id: x.title_id, text: "#{x.title}"}
  end
  @levels = leveltemp.to_json

  @functionmaster = TmeListFunction.all
  functemp = []
  @functionmaster.each do |x|
     functemp << {id: x.function_id, text: "#{x.function}"}
  end
  @functions = functemp.to_json

  @scmaster = SkillCategory.all   #Skill Category Master
  cattemp = []
     @scmaster.each do |x|
     cattemp << {value: x.id, text: "#{x.categoryname}"}
  end
  @skillcat= cattemp.to_json

  @lmaster = TmeListLanguage.all
  ltemp = []
     @lmaster.each do |x|
     ltemp << {value: x.language_id, text: "#{x.language}"}
  end
  @langlist= ltemp.to_json
  @sr = SkillRank.all
  erb :"dash/settings", :layout => false

end




#===============================AJAX Listing Section================================
get '/getskill' do
      smaster = SkillSource.all(:skillcategory_id => params["value"])
      sltemp=[]
         smaster.each do |x|
            sltemp << {value: x.id, text: "#{x.skill_name}"}    
         end

     sltemp.to_json
end


get '/getcoysize' do
       smaster = TmeListCompanysize.all
       stemp = []
           smaster.each do |x|
           stemp << {value: x.companysize_id, text: "#{x.companysize}"}
        end
        stemp.to_json
end

get '/getfunction' do
  functionmaster = TmeListFunction.all
  ftemp = []
  functionmaster.each do |x|
   ftemp << {value: x.function_id, text: "#{x.function}"}
  end
  ftemp.to_json
end    


get '/getworktime' do  
  worktimemaster = TmeListWorktime.all
  wtemp = []
  worktimemaster.each do |x|
    wtemp << {value: x.worktime_id, text: "#{x.worktime}"}
  end
  wtemp.to_json
end


get '/getind' do
  indmaster = TmeListIndustry.all
  itemp = []
  indmaster.each do |x|
   itemp << {value: x.industry_id, text: "#{x.industry}"}
  end
  itemp.to_json
end

get '/getcountries' do
  cmaster = TmeListCountry.all
  ctemp = []
  cmaster.each do |x|
    ctemp << {value: x.country_id, text: "#{x.country}"}
  end
  countries = ctemp.to_json
end

get '/getjobtitle' do
  titlemaster = TmeListTitle.all   #job title
  ttemp = []
  titlemaster.each do |x|
    ttemp << {value: x.title_id, text: "#{x.title}"}
  end
  ttemp.to_json
end


get '/getspecialty' do
  specialtymaster = TmeListSpecialty.all
  stemp = []
  specialtymaster.each do |x|
    stemp << {value: x.specialty_id, text: "#{x.specialty}"}
  end
  stemp.to_json    
end

get '/getpref' do
       prefmaster = TmeListNeedstrength.all
       ptemp = []
             prefmaster.each do |x|
           ptemp << {value: x.needstrength_id, text: "#{x.needstrength}"}
        end
        ptemp.to_json    
end

get '/getuni' do
       unimaster = TmeListUniversity.all
       utemp = []
             unimaster.each do |x|
           utemp << {value: x.university_id, text: "#{x.university}"}
        end
        utemp.to_json    
end

get '/gethonors' do
       honorsmaster = TmeListHonors.all
       htemp = []
             honorsmaster.each do |x|
             htemp << {value: x.honors_id, text: "#{x.honors}"}
             end

        htemp.to_json      
end

get '/getcert' do
  certmaster = TmeListCert.all
  certtemp = []
  certmaster.each do |x|
    certtemp << {value: x.cert_id, text: "#{x.cert}"}
  end
  certtemp.to_json    
end

get '/getskillcat' do
  scmaster = SkillCategory.all   #Skill Category Master
  cattemp = []
  scmaster.each do |x|
    cattemp << {value: x.id, text: "#{x.categoryname}"}
  end
  cattemp.to_json
end

get '/getlanguage' do
       lmaster = TmeListLanguage.all
       ltemp = []
             lmaster.each do |x|
                ltemp << {value: x.language_id, text: "#{x.language}"}
            end
      ltemp.to_json
end

get '/getdegree' do
      @degreemaster = TmeListDegree.all
       dtemp = []
             @degreemaster.each do |x|
                dtemp << {value: x.degree_id, text: "#{x.degree}"}
             end
        @degree = dtemp.to_json    
end

post '/getexperience' do
      @exp = TmeSkrEmp.get(params["pk"])
      @start = @exp.skr_emp_start.strftime("%d-%m-%Y").to_s
      if !@exp.skr_emp_currentjob
        @end = @exp.skr_emp_end.strftime("%d-%m-%Y").to_s
      end

      erb :"editexpmodalbody", :layout => false
end

post '/getcvskill' do
        #user = env['warden'].user
        user = User.get(params["pk"])
        userprofile = user.tme_skr_main
        @allskills =   userprofile.skill_summaries.all(:order => [ :skillrank.desc ], :status.gt =>0)
        @ssmaster = SkillSource
        erb :"cvskillmodalbody", :layout => false
end


#===============================Authentication Section================================
get '/auth/login' do
  erb :"main/login/index", :layout => :'main/layout1'
end

#get '/auth/elogin' do #recruiter login
#  erb :"main/login/eindex", :layout => :'main/layout1'
#end

get '/auth/unauthorized' do
  erb :"dash/unauthorized", :layout => false
end

post '/auth/login' do
  env['warden'].authenticate!
  if session[:return_to].nil?
    user = env['warden'].user
    if user.usertype == 1
      redirect '/edge'
    else
      redirect '/hrm'
    end
  else
    #redirect session[:return_to]
  end
end

get '/logout' do
  env['warden'].raw_session.inspect
  env['warden'].logout
  session.clear
  redirect '/auth/login'
end

post '/auth/unauthenticated' do
  redirect '/auth/login'
  end


#===============================TmeJobMain Section================================

  post '/updatejobclosingdate' do
    jobdata = TmeJobMain.get(params["pk"])
    str=params["job_closed"]
    date=Date.parse str
    jobdata.update(:job_closed => date)
    return 200
  end

  post '/updatejobstatus' do
    jobdata = TmeJobMain.get(params["pk"])
    jobdata.update(:job_status=> params["value"])
    return 200
  end

  post '/updatenationalityall' do
    jobdata = TmeJobMain.get(params["pk"])
    jobdata.update(:job_nationalityall => params["job_nationalityall"])
    {:responsemsg => jobdata.job_nationalityall}.to_json
  end

  post '/updateemergencyhour' do
    jobdata = TmeJobMain.get(params["pk"])
    jobdata.update(:job_workemergency => params["job_workemergency"])
    return 200
  end


  post '/updatenationalitypr' do
    jobdata = TmeJobMain.get(params["pk"])
    jobdata.update(:job_nationalitypr => params["job_nationalitypr"])
    return 200
  end

  post '/updateworkemergency' do
    jobdata = TmeJobMain.get(params["pk"])
    jobdata.update(:job_workemergency => params["job_workemergency"])
    return 200
  end

  post '/updaterevealcoy' do #/companyprofile
    jobdata = TmeJobMain.get(params["pk"])
    jobdata.update(:job_companyreveal => params["job_companyreveal"])
    return 200
  end

  post '/updatejob' do #/companyprofile
    jobdata = TmeJobMain.get(params["pk"])
    jobdata.update(eval(":#{params['name']}") => params["value"])
    return 200
  end

  post '/deletejob' do
    jobid = params["pk"]
    jobdata = TmeJobMain.get(jobid)
    jobdata.update(:job_status => 0)
  end


  post '/deleteexp' do
    expid = params["pk"]
    exp = TmeSkrEmp.get(expid)
    exp.update(:skr_empstatus => 0)
  end

  post '/deleteskill' do
    myskill = SkillSummary.get(params["pk"])
    myskill.update(:status => 0)
    return 200
  end

  post '/deletelanguage' do
    mylanguage =TmeSkrLanguage.get(params["pk"])
    mylanguage.update(:skr_status => 0)
    return 200
  end

  post '/deleteedu' do
    myedu= TmeSkrEdu.get(params["pk"])
    myedu.update(:skr_edustatus => 0)
    return 200
  end

  post '/deletecert' do
    mycert = TmeSkrCert.get(params["pk"])
    mycert.update(:skr_certstatus => 0)
    return 200
  end

  post '/j_deleteskill' do
    jobid = params["jobid"]
    job = TmeJobMain.get(jobid)
    jobskill = job.tme_job_skill.get(params["pk"])
    jobskill.update(:job_skillstatus => 0)
    return 200
  end

  post '/j_deletelanguage' do
    jobid = params["jobid"]
    job = TmeJobMain.get(jobid)
    joblanguage = job.tme_job_lang.get(params["pk"])
    joblanguage.update(:job_langstatus => 0)
    return 200
  end

  post '/j_deleteedu' do
    eduid = params["pk"]
    edu = TmeJobEdu.get(eduid)
    edu.update(:job_edustatus => 0)
    return 200
  end

  post '/j_deletecoyuser' do
    userid = params["pk"]
    user = User.get(userid)
    user.update(:status=> 2) #0 inactive, 1 active, 2 removed
    return 200
  end

  post '/j_deletecert' do
    certid = params["pk"]
    cert = TmeJobCert.get(certid)
    cert.update(:job_certstatus => 0)
    return 200
  end


  post '/j_newskill' do

    @jobid = params["pk"]
    @job = TmeJobMain.get(@jobid)

    if params["skillid"] == nil || params["skillrank"] == nil
      {:errors => "All fields are required!" }.to_json
    else
      newskill = TmeJobSkill.first_or_create({:job_skill => params["skillid"],:tme_job_main_id => @jobid}).update(:job_skillrating => params["skillrank"], :tme_job_main_id => @jobid, :job_skillstatus =>2) 
      {:responsemsg => "New skill added!" }.to_json
    end


  end

  post '/j_newlanguage' do
    @jobid = params["pk"]
    @job = TmeJobMain.get(@jobid)

    if params["job_lang"] == nil || params["job_lang_speakskill"] == nil || params["job_lang_writeskill"] == nil
      {:errors => "All fields are required!" }.to_json
    else
    newlanguage = TmeJobLang.first_or_create({:job_lang => params["job_lang"], :tme_job_main_id => @jobid}).update(:job_lang_speakskill => params["job_lang_speakskill"], :job_lang_writeskill => params["job_lang_writeskill"], :tme_job_main_id => @jobid, :job_langstatus =>2)
        {:responsemsg => "New Language Requirement Added!" }.to_json
    end
  end

  post '/j_newedu' do
    @jobid = params["pk"]
    #@job = TmeJobMain.get(@jobid)

    if params["job_edu_title"] == nil || params["job_edu_pref"] == nil
      {:errors => "All fields are required!" }.to_json
    else
    newedu = TmeJobEdu.first_or_create({:job_edu_title => params["job_edu_title"],  :tme_job_main_id => @jobid}).update(:job_edu_title => params["job_edu_title"], :job_edu_specialty => params["job_edu_specialty"], :job_edu_honors => params["job_edu_honors"], :job_edu_pref => params["job_edu_pref"], :tme_job_main_id => @jobid, :job_edustatus =>2)
        {:responsemsg => "New Education Requirement Added!" }.to_json
    end
  end

  post '/j_newcert' do
    @jobid = params["pk"]
    if params["job_cert_title"] == nil || params["job_cert_pref"] == nil
      {:errors => "All fields are required!" }.to_json
    else
    newcert = TmeJobCert.first_or_create({:job_cert_title => params["job_cert_title"], :tme_job_main_id => @jobid}).update(:job_cert_title => params["job_cert_title"], :job_cert_pref => params["job_cert_pref"], :tme_job_main_id => @jobid, :job_certstatus =>2)
        {:responsemsg => "New Certificate Requirement Added!" }.to_json
    end
  end


  post '/newcoyuser' do
    newcoyuser = User.first_or_create({:username => params["email"]}).update(:firstname => params["firstname"], :middlename => params["middlename"], :lastname => params["lastname"], :email => params["email"], :contactnumber =>params["contactnumber"], :password => params["password"], :tme_company_main_id => params["pk"], :usertype => 2)
    {:responsemsg => "New Company User Added!" }.to_json
  end

  get '/newjob' do
    job = TmeJobMain.create(:tme_company_main_id => params["value"])
    {jobid: job.id, mycoy: params["value"]}.to_json
  end


  #get '/newuser' do
  #  user = User.create()
  #  #In the erb, when user enter a username, go to get "/check username". If username is found, then give them the option to pull the entire record.
  #  tmeskrmain = TmeSkrMain.create()
  #  #we need to update the user.tme_skr_main.id with tmeskrmain.id
  #  {userid: user.id, tmeskrmainid: tmeskrmain.id}.to_json
  #end


post '/jobdetail' do
   @jobid = params["pk"]
   @job = TmeJobMain.get(@jobid)
   if @job.job_nationality != nil
    @nationalitymaster = TmeListCountry.all(:country_id => @job.job_nationality).first.country
   end

   if @job.job_closed ==nil
    @job_closed =" "
    else @job_closed = @job.job_closed.strftime("%d/%m/%Y")
    end

   if @job.job_status == 0
    @jobstatus = "Deleted"
   elsif @job.job_status == 1
    @jobstatus = "Pending"
   elsif @job.job_status == 2
    @jobstatus = "Active"
   elsif @job.job_status == 3
    @jobstatus = "Closed"
   elsif @job.job_status == 4
    @jobstatus = "Draft"
   else @jobstatus = "NA"
   end

   erb :jobdetail, :layout => false

end


post '/newjobdetail' do
   @jobid = params["pk"]
   @job = TmeJobMain.get(@jobid)
   mycoy = TmeCompanyMain.get(params["coy"])
   if !mycoy.company_isagent
    @industry = mycoy.company_industry
   else
    @industry = ""

   end
   puts mycoy.company_isagent
   puts @industry
   @job_closed = @job.job_closed.strftime("%d/%m/%Y")

   if @job.job_status == 0
    @jobstatus = "Deleted"
   elsif @job.job_status == 1
    @jobstatus = "Pending"
   elsif @job.job_status == 2
    @jobstatus = "Active"
   elsif @job.job_status == 3
    @jobstatus = "Closed"
   elsif @job.job_status == 4
    @jobstatus = "Draft"
   else @jobstatus = "NA"
   end
   erb :newjobdetail, :layout => false

end

post '/coyuserdetail' do
   @coyuserid = params["pk"]   #pk is passed from j_coyusertable.erb
   @coyuser = User.get(@coyuserid)

   erb :coyuserdetail, :layout => false

end


get '/j_mycv' do
       redirect '/auth/login' unless env['warden'].authenticated?
       @user = User.get(params["pk"])
       if @user.usertype == 1
        redirect '/auth/unauthorized'
       end
       @userprofile = @user.tme_skr_main
       @userme = @user.firstname
       @mycoy = @user.tme_company_main
       @cmaster = TmeListCountry
       @uni = TmeListUniversity
       @degree = TmeListDegree
       @allskills =   @userprofile.skill_summaries.all(:order => [ :skillrank.desc ], :limit => 10, :status.gt =>0)
       @alledu =   @userprofile.tme_skr_edu.all
       @alljobs = @userprofile.tme_skr_emp.all
       @ssmaster = SkillSource  #master skill source for cross referencing
       @mynations=@userprofile.tme_skr_nation.first(:tme_skr_main_id=>@userprofile.id).skr_nation
       @mynationtypes=@userprofile.tme_skr_nation.first(:tme_skr_main_id=>@userprofile.id).skr_nation_type
       @allachievements = @userprofile.tme_skr_achieve.all
       erb :j_mycv, :layout => :'main/layout3'
end



get '/companyprofile' do
       redirect '/auth/login' unless env['warden'].authenticated?
       @user = env['warden'].user
       if @user.usertype == 1
          redirect '/auth/unauthorized'
       end
       @userprofile = @user.tme_skr_main
       @userme = @user.firstname
       @mycoy = @user.tme_company_main
       #@joblisting = @mycoy.tme_job_main.all

       #@mycoyusers = TmeCompanyUsers

       erb :"dash/companyprofile", :layout => :'dash/layout2'
end


################ CREATING NEW JOB SEEKERS IN ADMIN CONSOLE ######################
  get '/newseeker' do
    user = User.create()
    #In the erb, when user enter a username, go to get "/check username". If username is found, then give them the option to pull the entire record.
    tmeskrmain = TmeSkrMain.create()
    #we need to update the user.tme_skr_main.id with tmeskrmain.id
    user.update(:tme_skr_main_id => tmeskrmain.id)
    user.update(:usertype => 1)
    achievements=TmeSkrAchieve.create()
    achievements.update(:tme_skr_main_id => tmeskrmain.id)
    nationality=TmeSkrNation.create()
    nationality.update(:tme_skr_main_id => tmeskrmain.id)
   

       @user = user
       @userprofile = tmeskrmain
       @userme = @user.firstname

       sc = @userprofile.tme_skr_socialmedia.create(:tme_skr_main_id => tmeskrmain.id, :skr_socialmediacat => 1)
       sc = @userprofile.tme_skr_socialmedia.create(:tme_skr_main_id => tmeskrmain.id, :skr_socialmediacat => 2)
       sc = @userprofile.tme_skr_socialmedia.create(:tme_skr_main_id => tmeskrmain.id, :skr_socialmediacat => 3)
       sc = @userprofile.tme_skr_socialmedia.create(:tme_skr_main_id => tmeskrmain.id, :skr_socialmediacat => 4)
       sc = @userprofile.tme_skr_socialmedia.create(:tme_skr_main_id => tmeskrmain.id, :skr_socialmediacat => 5)

       @cmaster = TmeListCountry.all
       ctemp = []
           @cmaster.each do |x|
           ctemp << {value: x.country_id, text: "#{x.country}"}
        end
        @countries = ctemp.to_json
       #erb :"dash/profile", :layout => :'dash/layout1'
       erb :"dash/admin_newseeker", :layout => :'dash/layout3'

  end




#################################################################################
  #post '/update_language' do
  #  redirect '/auth/login' unless env['warden'].authenticated?
  #  u = env['warden'].user
  #  userprofile = u.tme_skr_main
  #  mylanguage = userprofile.languages.get(params["pk"])
  #  mylanguage.update(:languageid => params["value"])
  #  mylanguage.update(:status =>1)
  #  return 200
  #end


 post '/updateaccesslevel' do #For j_coyusertable.erb
    userprofile= User.get(params["pk"])
    userprofile.update(:accesslevel => params["value"])
    return 200
  end

 post '/updatestatus' do #For j_coyusertable.erb
    userprofile= User.get(params["pk"])
    userprofile.update(:status => params["value"])
    return 200
  end



post '/j_updateskillrank' do
    jobskillid = params["pk"]
    jobskill = TmeJobSkill.get(jobskillid)
    jobskill.update(:job_skillrating => params["value"])
    jobskill.update(:job_skillstatus =>1)
    return 200
  end


 post '/j_updatelang_speakskill' do
    joblangid = params["pk"]
    joblang = TmeJobLang.get(joblangid)
    joblang.update(:job_lang_speakskill => params["value"])
    joblang.update(:job_langstatus =>1)
    return 200
  end


 post '/j_updatelang_writeskill' do
    joblangid = params["pk"]
    joblang = TmeJobLang.get(joblangid)
    joblang.update(:job_lang_writeskill => params["value"])
    joblang.update(:job_langstatus =>1)
    return 200
  end

 post '/j_updateedupref' do
    jobeduid = params["pk"]
    jobedu = TmeJobEdu.get(jobeduid)
    jobedu.update(:job_edu_pref => params["value"])
    jobedu.update(:job_edustatus =>1)
    return 200
  end

 post '/j_updatecertpref' do
    jobcertid = params["pk"]
    jobcert = TmeJobCert.get(jobcertid)
    jobcert.update(:job_cert_pref => params["value"])
    jobcert.update(:job_certstatus =>1)
    return 200
  end



    post '/updatelocpref' do
     u = User.get(params["pk"])
     userprofile = u.tme_skr_main
     #First delete all preferred locations in table.
     oldloc = userprofile.tme_skr_prefloc.all
     oldloc.each do |x|
      x.destroy
     end
     loc =params["value"]
     if loc != nil  #If user does nto enter any value, then just return back
       #traverse array
       loc.each { |x| userprofile.tme_skr_prefloc.create(:skr_prefloc => x)}
     end
    end

    post '/updateindpref' do
     u = User.get(params["pk"])
     userprofile = u.tme_skr_main
     #First delete all preferred industries in table.
     oldind = userprofile.tme_skr_prefind.all
     oldind.each do |x|
      x.destroy
     end
     ind =params["value"]
     if ind != nil  #If user does nto enter any value, then just return back
       #traverse array
       ind.each { |x| userprofile.tme_skr_prefind.create(:skr_prefind => x)}
     end
    end

    post '/updatelevelpref' do

     u = User.get(params["pk"])
     userprofile = u.tme_skr_main
     #First delete all preferred levels in table.
     oldlevel = userprofile.tme_skr_preftitle.all
     oldlevel.each do |x|
      x.destroy
     end
     #level = []
     #level = params["value"].split(",").map(&:to_i) #string to array
     level =params["value"]
     if level != nil  #If user does nto enter any value, then just return back
       #traverse array
       level.each { |x| userprofile.tme_skr_preftitle.create(:skr_preftitle => x)}
     end

  end

    post '/updatefuncpref' do
     u = User.get(params["pk"])
     userprofile = u.tme_skr_main
     #First delete all preferred levels in table.
     oldfunc = userprofile.tme_skr_preffunc.all
     oldfunc.each do |x|
      x.destroy
     end
     func =params["value"]
     if func != nil
        #traverse array
        func.each { |x| userprofile.tme_skr_preffunc.create(:skr_preffunc => x)}
      end
  end

 post '/table' do
       u = User.get(params["pk"])
       @userprofile = u.tme_skr_main
       @allskills =   @userprofile.skill_summaries.all
       @ssmaster = SkillSource  #master skill source for cross referencing
       @scmaster = SkillCategory.all   #Skill Category Master     #Hardcode to HTML. Remove from Database. Push this to the /admin for churning json.
       @sr = SkillRank.all
       erb :table, :layout => false

    end

 post '/langtable' do
       u = User.get(params["pk"])
       @userprofile = u.tme_skr_main
       @alllanguages =   @userprofile.tme_skr_language.all
       @lmaster = TmeListLanguage.all
       @sr = SkillRank.all  #Hardcode to HTML. Remove from Database.
       erb :langtable, :layout => false

    end

 post '/edutable' do
       u = User.get(params["pk"])
       @userprofile = u.tme_skr_main
       @alleducations = @userprofile.tme_skr_edu.all
       @honorsmaster = TmeListHonors.all
       @specialtymaster = TmeListSpecialty.all
       @degreemaster = TmeListDegree.all
       erb :edutable, :layout => false
    end

 post '/certtable' do

       u = User.get(params["pk"])
       @userprofile = u.tme_skr_main
       @allcertificates = @userprofile.tme_skr_cert.all(:tme_skr_main_id => @userprofile.id)
       @allcertinst =TmeListCertinst.all
       @certmaster = TmeListCert.all
       erb :certtable, :layout => false
    end

 post '/experiencetable' do

       u = User.get(params["pk"])
       @userprofile = u.tme_skr_main
       @allexperiences = @userprofile.tme_skr_emp.all(:tme_skr_main_id => @userprofile.id)
       #@titlemaster = TmeListTitle.all
       #@indmaster = TmeListIndustry.all
       #@locationmaster = TmeListCountry.all
       #@functionmaster = TmeListFunction.all
       erb :experiencetable, :layout => false
    end


 post '/activejobtable' do
       userprofile = env['warden'].user
       mycoy = userprofile.tme_company_main      
       #@joblisting = mycoy.tme_job_main.all(:job_status =>1) | mycoy.tme_job_main.all(:job_status =>2)
       @joblisting = mycoy.tme_job_main.all
       @titlemaster = TmeListTitle.all
       erb :activejobtable, :layout => false

    end

 post '/activejobtable-hrm' do
       userprofile = env['warden'].user
       mycoy = userprofile.tme_company_main      
       #@joblisting = mycoy.tme_job_main.all(:job_status =>1) | mycoy.tme_job_main.all(:job_status =>2)
       @joblisting = mycoy.tme_job_main.all
       @titlemaster = TmeListTitle.all
       erb :"activejobtable-hrm", :layout => false

    end

 post '/closedjobtable' do
       userprofile = env['warden'].user
       mycoy = userprofile.tme_company_main      
       #@joblisting = mycoy.tme_job_main.all(:job_status =>0) | mycoy.tme_job_main.all(:job_status =>3)
       @joblisting = mycoy.tme_job_main.all
       @titlemaster = TmeListTitle
       erb :closedjobtable, :layout => false

    end


 post '/j_table' do
       @jobid = params["pk"]
       @job = TmeJobMain.get(@jobid)
       @allskills =   @job.tme_job_skill.all
  
       @ssmaster = SkillSource  #master skill source for cross referencing
       @scmaster = SkillCategory.all   #Skill Category Master    
       @sr = SkillRank.all
       erb :j_table, :layout => false

    end

 post '/j_langtable' do
       @jobid = params["pk"]
       @job = TmeJobMain.get(@jobid)
       @alllanguages = @job.tme_job_lang.all
       @lmaster = TmeListLanguage.all
       @sr = SkillRank.all
       erb :j_langtable, :layout => false

    end

 post '/j_edutable' do
       @jobid = params["pk"]
       @job = TmeJobMain.get(@jobid)
       @alleducations = @job.tme_job_edu.all
       @honorsmaster = TmeListHonors.all
       @prefmaster = TmeListNeedstrength.all
       @specialtymaster = TmeListSpecialty.all
       @degreemaster = TmeListDegree.all
       erb :j_edutable, :layout => false
    end

 post '/j_certtable' do
       @jobid = params["pk"]
       @job = TmeJobMain.get(@jobid)
       @allcertificates = @job.tme_job_cert.all(:tme_job_main_id => @jobid)
       #@allcertificates = @job.tme_job_cert.all
       @allcertinst =TmeListCertinst.all
       @certmaster = TmeListCert.all
       @prefmaster = TmeListNeedstrength.all

       erb :j_certtable, :layout => false
    end

 post '/j_coyusertable' do
        @users = User.all


       erb :j_coyusertable, :layout => false
    end

post '/updatefacebook' do
  user = env['warden'].user
  userprofile = user.tme_skr_main
  TmeSkrSocialmedia.first_or_create({:skr_socialmediacat=>1, :tme_skr_main_id=> params["pk"]}).update(:skr_socialmediaurl=> params['value'])
      {:responsemsg => "Facebook URL updated" }.to_json
end

post '/updatelinkedin' do
  user = env['warden'].user
  userprofile = user.tme_skr_main
  TmeSkrSocialmedia.first_or_create({:skr_socialmediacat=>3, :tme_skr_main_id=> params["pk"]}).update(:skr_socialmediaurl=> params["value"])
      {:responsemsg => "LinkedIn URL updated" }.to_json
end

post '/updatetwitter' do
  user = env['warden'].user
  userprofile = user.tme_skr_main
  TmeSkrSocialmedia.first_or_create({:skr_socialmediacat=>4, :tme_skr_main_id=> params["pk"]}).update(:skr_socialmediaurl=> params["value"])
      {:responsemsg => "Twitter URL updated" }.to_json
end

#===============================Cloudinary Upload Section================================
get '/filer' do
  user = User.get(params["userid"])
  #userprofile = u.tme_skr_main
  ts = Time.now.getutc.to_time.to_i.to_s
  secret="fbOQxgozjYG2acAMKi3FYL61LOI"
  altogether="callback=http://dashy3.herokuapp.com/vendor/cloudinary/cloudinary_cors.html&public_id=#{user.username}&timestamp="+ts+secret
  sig=Digest::SHA1.hexdigest altogether
  ts = Time.now.getutc.to_time.to_i
  {:timestamp => ts, :public_id => "#{user.username}", :callback => "http://dashy3.herokuapp.com/vendor/cloudinary/cloudinary_cors.html", :signature => sig, :api_key =>"219441847515364"}.to_json
 end

get '/filer_cv' do
  user = User.get(params["userid"])
  #userprofile = user.tme_skr_main
  ts = Time.now.getutc.to_time.to_i.to_s
  secret="fbOQxgozjYG2acAMKi3FYL61LOI"
  altogether="callback=http://dashy3.herokuapp.com/vendor/cloudinary/cloudinary_cors.html&public_id=cv/#{user.username}&timestamp="+ts+secret
  sig=Digest::SHA1.hexdigest altogether
  ts = Time.now.getutc.to_time.to_i
  {:timestamp => ts, :public_id => "cv/#{user.username}", :callback => "http://dashy3.herokuapp.com/vendor/cloudinary/cloudinary_cors.html", :signature => sig, :api_key =>"219441847515364"}.to_json
 end

get '/filer_jd' do
  coy = u.tme_company_main
  jobid = coy.tme_job_main.get(params["pk"]).id.to_s 
  ts = Time.now.getutc.to_time.to_i.to_s
  secret="fbOQxgozjYG2acAMKi3FYL61LOI"
  altogether="callback=http://dashy3.herokuapp.com/vendor/cloudinary/cloudinary_cors.html&public_id=jd/#{jobid}&timestamp="+ts+secret
  sig=Digest::SHA1.hexdigest altogether
  ts = Time.now.getutc.to_time.to_i
  {:timestamp => ts, :public_id => "jd/#{jobid}", :callback => "http://dashy3.herokuapp.com/vendor/cloudinary/cloudinary_cors.html", :signature => sig, :api_key =>"219441847515364"}.to_json
end

get '/filer_logo' do
  u = env['warden'].user
  coy = u.tme_company_main
  coyid= coy.id.to_s
  ts = Time.now.getutc.to_time.to_i.to_s
  secret="fbOQxgozjYG2acAMKi3FYL61LOI"
  altogether="callback=http://dashy3.herokuapp.com/vendor/cloudinary/cloudinary_cors.html&public_id=logo/#{coyid}&timestamp="+ts+secret
  sig=Digest::SHA1.hexdigest altogether
  ts = Time.now.getutc.to_time.to_i
  {:timestamp => ts, :public_id => "logo/#{coyid}", :callback => "http://dashy3.herokuapp.com/vendor/cloudinary/cloudinary_cors.html", :signature => sig, :api_key =>"219441847515364"}.to_json
 end

 post '/cvuploaded' do
      userdata = User.get(params["pk"])
      userdata.tme_skr_main.update(:cvurl => params['cvurl'])
      return 200
 end

 post '/picuploaded' do
      userdata = User.get(params["pk"])
      userdata.update(:pictureurl => params['picurl'])
      return 200
 end

 post '/jduploaded' do
      u = env['warden'].user
      coy = u.tme_company_main  
      jobdata= coy.tme_job_main.get(params["pk"])  
      jobdata.update(:job_jdurl => params['jdurl'])
      return 200
 end

 post '/logouploaded' do
      u = env['warden'].user
      coy = u.tme_company_main   
      coy.update(:company_logo => params['company_logo'])
      return 200
 end



end
 

run SinatraWardenExample
