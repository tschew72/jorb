require 'rubygems'
require 'data_mapper'
require 'dm-postgres-adapter'
require 'bcrypt'
require 'dm-validations'

DataMapper.setup(:default, "postgres://pmfpekijznvzjw:Hq_zObLrI-YKpLoHpKKy0QLgsH@ec2-54-225-101-164.compute-1.amazonaws.com:5432/d3ev2r7degfpm9")



class User
  include DataMapper::Resource
  include BCrypt
  storage_names[repository = :default] = 'tme_users'
  property :id, Serial, key: true, :index => true, :field => 'username_id'
  property :username, String, :index => true, length: 50, :index => true 
  property :usertype, Integer                                     ###########1 seeker, 2 Company user
  property :password,  BCryptHash, :index => true
  property :email, String, :default=>"your@email.com", length:200, format: :email_address, :index => true
  property :lastname, String, :index => true,  :default=>"", length:100, :field => 'surname'
  property :firstname, String, :default=>"", length: 100, :index => true
  property :middlename, String, :default=>"", length: 100, :index => true
  #property :activeseeker, Boolean, :index => true, :default =>true, :field => 'active'
  property :datejoined, Date, :index => true, :default => lambda{ |p,s| Date.today} 
  property :updated_at, DateTime, :index => true, :field => 'updated'
  property :contactnumber, String, length: 20, :index => true
  property :accesslevel, Integer, :default => 2                   #############0 NA 1 Admin User 2 Job Poster 3 SuperAdmin
  property :pictureurl, String, :index => true, length: 1000, :default=>"/images/default-avatar.jpg"
  property :tme_company_main_id, Integer, :field => 'company_id'
  property :tme_skr_main_id, Integer, :field => 'skr_id'
  property :status, Integer, :default => 1                        ############## 0 Inactive #  1 active   2 Removed
  #property :lastlogin, Date, :index => true, :field => 'skr_lastlogin' To be used later.
  belongs_to :tme_skr_main, :model =>'TmeSkrMain'
  belongs_to :tme_company_main, :model =>'TmeCompanyMain'


  def authenticate(attempted_password)
    if self.password == attempted_password
      true
    else
      false
    end
  end

end




# class User  
class TmeSkrMain
  include DataMapper::Resource
  include BCrypt
  storage_names[repository = :default] = 'tme_skr_main'
  property :id, Serial, key: true, :index => true, :field => 'skr_id'
  property :activeseeker, Boolean, :index => true, :default =>true, :field => 'skr_active'
  #property :lastname, String, :index => true,  :default=>"", length:100, :field => 'skr_surname'
  #property :firstname, String, :default=>"", length: 100, :index => true, :field => 'skr_firstname'
  #property :middlename, String, :default=>"", length: 100, :index => true, :field => 'skr_middlename'
  property :reveal, Boolean, :index => true, :field => 'skr_reveal'
  #property :email, String, :default=>"your@email.com", length:80, format: :email_address, :index => true, :field => 'skr_email' 
  property :dob, Date, :index => true, :field => 'skr_birthdate' 
  property :gender, Integer, :index => true, :default => 1, :field => 'skr_gender'
  property :married, Boolean, :index => true, :default=>false,  :field => 'skr_married'  
  property :datejoined, Date, :index => true, :field => 'skr_datejoined'
  property :availability, Integer, :index => true, :field => 'skr_availability' # notice period
  #property :updated_at, DateTime, :index => true, :field => 'skr_updated'

  # property :pictureurl, String, :index => true, length: 400, :default=>"", :field => 'skr_photo'  #setup a default picture if not picture is found
  property :cvurl, String, :index => true, length: 400, :default=>"", :field => 'skr_cv' 
  property :videourl, String, :index => true, length: 400, :default=>"", :field => 'skr_video'   
  property :username, String, :index => true, length: 50, :index => true, :field => 'skr_username'  
  property :prefind_all, Boolean, :index => true, :default =>true,:field => 'skr_prefind_all' # no preference. If field is NIL, set this to true.
  property :prefjobfunc_all, Boolean, :index => true, :default =>true,:field => 'skr_prefjobfunc_all' # no preference
  property :prefjobtitle_all, Boolean, :index => true, :default =>true,:field => 'skr_prefjobtitle_all' # no preference
  property :prefloc_all, Boolean, :index => true, :default =>true,:field => 'skr_prefloc_all' # no preference
  property :currentsalary, Integer, :default => 0, :index => true, :field => 'skr_currsalary'
  property :expectedsalary,  Integer, :default => 0, :index => true, :field => 'skr_prefsalary'
  property :salarycurrency,  Integer, :default => 1, :index => true, :field => 'skr_salarycurrency'
  property :parttime,  Boolean, :default=>false, :index => true, :field => 'skr_parttime'
  property :fulltime,  Boolean, :default=>false, :index => true, :field => 'skr_fulltime'
  property :shiftwork,  Boolean, :default=>false, :index => true, :field => 'skr_shiftwork'
  property :outofhours,  Boolean, :default=>false, :index => true, :field => 'skr_emergency'
  property :skr_intern, Boolean, :default=>false, :index => true
  property :skr_contractor, Boolean, :default=>false, :index => true
  property :travelfreq,  Integer, :default=>0, :index => true, :field => 'skr_preftravel'
  # property :password,  BCryptHash, :index => true,:field => 'skr_password'
  property :age,  Integer, :index => true, :field => 'skr_age'
  property :aboutme,  String, length: 255, :index => true, :field => 'skr_aboutme'     #not used 
  # property :skr_achieve, String, length:50000
  property :insingaporenow, Boolean, :index => true, :default =>true, :field => 'skr_insingaporenow'    
  property :insg_start, Date, :index => true, :field => 'skr_insgstart', :default => lambda{ |p,s| Date.today}  
  property :insg_end, Date, :index => true, :field => 'skr_insgend', :default => lambda{ |a,b| Date.today>>1} 
  
  #property :singaporepr, Boolean, :index => true, :default  => false, :field => 'skr_singaporepr'
  property :address, String, length: 5000, :index => true, :field => 'skr_address'
  #property :contactnumber, String, length: 20, :index => true, :field => 'skr_contactnumber' #created a new column in table
  property :skr_careergoal, String,length: 5000, :default=>"", :index => true
 
  # property :tme_company_main_id, Integer, :index => true, :field => 'company_id'  
  # belongs_to :tme_company_main

  has n, :matched_jobs   #???
  has n, :jobs  #???
  has 1, :career_score
  has n, :skill_summaries
  has n, :job_industries
  has n, :preferred_locations
  has n, :tme_skr_socialmedia, :model => 'TmeSkrSocialmedia'
  has n, :tme_skr_prefloc, :model => 'TmeSkrPrefloc'
  has n, :tme_skr_preftitle, :model => 'TmeSkrPreftitle'
  has n, :tme_skr_preffunc, :model => 'TmeSkrPreffunc'
  has n, :tme_skr_prefind, :model => 'TmeSkrPrefind'
  has n, :tme_skr_skill, :model => 'SkillSummary'
  has n, :tme_skr_language, :model =>'TmeSkrLanguage'
  has n, :tme_skr_edu, :model => 'TmeSkrEdu'
  has n, :tme_skr_emp, :model => 'TmeSkrEmp'
  has 1, :skrscore, :model =>'Skrscore'
  has n, :tme_skr_nation, :model =>'TmeSkrNation'
  has n, :tme_skr_achieve, :model =>'TmeSkrAchieve'
  has n, :tme_skr_cert, :model =>'TmeSkrCert'
  has 1, :tme_users, :model =>'User'
  

  def authenticate(attempted_password)
    if self.password == attempted_password
      true
    else
      false
    end
  end

end

class TmeSkrSocialmedia
    include DataMapper::Resource
    storage_names[repository = :default] ='tme_skr_socialmedia'
    property :skr_socialmedia_id, Serial, key: true   
    property :tme_skr_main_id, Integer, :field => 'skr_id'
    property :skr_socialmediacat, Integer
    property :skr_socialmediaurl, String, :default => ""

    belongs_to :tme_skr_main 
end


class TmeSkrCert
    include DataMapper::Resource
    storage_names[repository = :default] ='tme_skr_cert'
    property :skr_cert_id, Serial, key: true   
    property :tme_skr_main_id, Integer, :field => 'skr_id'
    property :skr_certtitle, Integer
    property :skr_certlicense, String  #license #
    property :skr_certexpiry, DateTime   #Expiry Date
    #property :skr_certdaterenew, DateTime 
    property :skr_datecertified, DateTime #when did he get certified?
    property :skr_certstatus,Integer

    belongs_to :tme_skr_main 
end

class TmeSkrPrefloc
    include DataMapper::Resource
    storage_names[repository = :default] = 'tme_skr_prefloc'
    property :skr_prefloc_id, Serial, key: true   
    property :tme_skr_main_id, Integer, :field => 'skr_id'
    property :skr_prefloc, Integer

    belongs_to :tme_skr_main 
end

class TmeSkrPreftitle #job level
    include DataMapper::Resource
    storage_names[repository = :default] = 'tme_skr_preftitle'
    property :skr_preftitle_id, Serial, key: true   
    property :tme_skr_main_id, Integer, :field => 'skr_id'
    property :skr_preftitle, Integer

    belongs_to :tme_skr_main 
end


class TmeSkrPreffunc #job Function
    include DataMapper::Resource
    storage_names[repository = :default] = 'tme_skr_preffunc'
    property :skr_preffunc_id, Serial, key: true   
    property :tme_skr_main_id, Integer, :field => 'skr_id'
    property :skr_preffunc, Integer

    belongs_to :tme_skr_main 
end

class TmeSkrPrefind #Preferred industry
    include DataMapper::Resource
    storage_names[repository = :default] = 'tme_skr_prefind'
    property :skr_prefind_id, Serial, key: true   
    property :tme_skr_main_id, Integer, :field => 'skr_id'
    property :skr_prefind, Integer

    belongs_to :tme_skr_main 
end


class TmeListCountry
    include DataMapper::Resource
    storage_names[repository = :default] = 'tme_list_country'
    property :country_id, Serial, key: true   
    property :country, String
end

class TmeListTitle  # Job Level
    include DataMapper::Resource
    storage_names[repository = :default] = 'tme_list_title'
    property :title_id, Serial, key: true   
    property :title, String
end

class TmeListFunction  # Job Function
    include DataMapper::Resource
    storage_names[repository = :default] = 'tme_list_function'
    property :function_id, Serial, key: true   
    property :function, String
end

class TmeListWorktime  # Job Function
    include DataMapper::Resource
    storage_names[repository = :default] = 'tme_list_worktime'
    property :worktime_id, Serial, key: true   
    property :worktime, String
end


class TmeListIndustry  # Job Function
    include DataMapper::Resource
    storage_names[repository = :default] = 'tme_list_industry'
    property :industry_id, Serial, key: true   
    property :industry, String
end

class Job
  include DataMapper::Resource

  property :id, Serial, key: true
  property :startdate, Date
  property :enddate, Date
  property :position, String, length:120  # Graduate in what...
  property :company, String, length:120   # School
  property :responsibilities, String, length:100000 #Grades
  property :achievements, String, length: 100000    #Projects
  property :user_id, Integer
  property :type, String, length:1 #to define if it is a job or education. J or E
  property :employerrating, Integer # to rate how good is this company in your opinion

  #next time can include an array of skills that are being used in a job
  belongs_to :tme_skr_main 
end


class TmeCompanyMain
  include DataMapper::Resource
  storage_names[repository = :default] = 'tme_company_main'
  property :id, Serial, key: true, :index=>true, :field => 'company_id'
  property :company_name, String, length: 500, :index=>true
  property :company_isagent, Boolean, :index=>true
  property :company_industry, Integer, :index=>true
  property :company_contactname, String, length: 500, :index=>true
  property :company_email, String, length: 200, :index=>true
  property :company_phone, String, :index=>true
  property :company_url, String, length: 500, :index=>true
  property :company_size, Integer, :index=>true
  property :company_hq, String, length: 2000, :index=>true
  property :company_linkedin, String, length: 500, :index=>true
  property :company_facebook, String, length: 500,  :index=>true
  property :company_twitter, String, length: 500,  :index=>true
  property :company_logo, String, length: 500, :default=>"/images/default-coy.jpg", :index=>true #URL
  property :company_workinghours, String,  :index=>true
  property :company_dresscode, String, length: 500,  :index=>true
  property :company_preflang, String, :index=>true
  property :company_promo, String, length: 10000,  :index=>true
  property :company_intro, String, length: 50000,  :index=>true
  property :company_dateadded, Date
  property :company_addrstreet1, String, length: 2000,  :index=>true
  property :company_addrstreet2, String, length: 2000,  :index=>true
  property :company_addrcity, String, length: 500, :index=>true
  property :company_addrcountry, Integer, :index=>true
  property :company_addrpostcode, String, length: 10, :index=>true

  has n, :tme_job_main, :model =>'TmeJobMain'
  #has n, :user
  has n, :tme_users, :model =>'User'
end


class TmeJobMain
  include DataMapper::Resource
  storage_names[repository = :default] = 'tme_job_main'
  property :id, Serial, key: true, :index=>true, :field => 'job_id'
  property :job_companyreveal, Boolean,:default=>false
  property :job_contactname, String, length: 120, :index=>true
  property :job_contactemail, String, length: 200, :index=>true
  property :job_contactphone, String, :index=>true
  property :job_posted, DateTime,:default => lambda{ |p,s| Date.today}, :index => true    
  property :job_closed, DateTime, :index => true, :default => lambda{ |a,b| Date.today>>6} 
  property :job_title, Integer, :index => true  
  property :job_location, Integer, :index => true  
  property :job_industry, Integer, :index => true  
  property :job_currency, Integer, :index => true  
  property :job_travel, Integer, :index => true  
  property :job_nationality, Integer, :index => true  
  property :job_salarymin, Integer, :index => true  
  property :job_salarymax, Integer, :index => true  
  property :job_experience, Integer, :index => true  
  property :job_time, Integer, :index => true  
  property :job_function, Integer, :index => true  
  property :tme_company_main_id, Integer, :index => true, :field => 'job_companyname'   
  property :job_jdurl, String, length: 1000, :index => true  
  property :job_nationalityall, Boolean, :index => true, :default => false
  property :job_nationalitypr, Boolean, :index => true, :default =>true
  property :job_workemergency, Boolean, :index=>true, :default => false
  
  property :job_status, Integer, :default => 4, :index => true #"0 = cancelled, 1 = pending, 2 = active, 3  = closed, 4 = draft"

  belongs_to :tme_company_main

  has n, :tme_job_skill, :model =>'TmeJobSkill'
  has n, :tme_job_lang, :model =>'TmeJobLang'
  has n, :tme_job_edu, :model =>'TmeJobEdu'
  has n, :tme_job_cert, :model =>'TmeJobCert'
end

class TmeJobSkill
  include DataMapper::Resource
  storage_names[repository = :default] = 'tme_job_skill'
  property :job_skill_id, Serial, key: true, :index=>true
  property :tme_job_main_id, Integer, :index=>true, :field => 'job_id' 
  property :job_skill, Integer, :index => true  
  property :job_skillrating, Integer, :index => true  
  #property :job_skillcat, Integer, :index => true  
  property :job_skillstatus, Integer, :index=>true
  belongs_to :tme_job_main 
end

class TmeJobLang
  include DataMapper::Resource
  storage_names[repository = :default] = 'tme_job_lang'
  property :job_lang_id, Serial, key: true, :index=>true
  property :tme_job_main_id, Integer, :index=>true, :field => 'job_id' 
  property :job_lang, Integer, :index => true  
  property :job_lang_speakskill, Integer, :index => true  
  property :job_lang_writeskill, Integer, :index => true  
  property :job_langstatus, Integer, :index=>true

  belongs_to :tme_job_main 
end

class TmeJobEdu
  include DataMapper::Resource
  storage_names[repository = :default] = 'tme_job_edu'
  property :job_edu_id, Serial, key: true, :index=>true
  property :tme_job_main_id, Integer, :index=>true, :field => 'job_id' 
  property :job_edu_title, Integer, :index => true  
  property :job_edu_specialty, Integer, :index => true  
  property :job_edu_honors, Integer, :index => true  
  property :job_edu_gpa, Integer, :index => true  
  property :job_edu_pref, Integer, :index => true  
  property :job_edustatus, Integer, :index => true  
  belongs_to :tme_job_main 
end

class TmeJobCert
  include DataMapper::Resource
  storage_names[repository = :default] = 'tme_job_cert'
  property :job_cert_id, Serial, key: true, :index=>true
  property :tme_job_main_id, Integer, :index=>true, :field => 'job_id' 
  property :job_cert_title, Integer, :index => true  
  property :job_cert_inst, Integer, :index => true  
  property :job_cert_pref, Integer, :index => true  
  property :job_certstatus, Integer, :index => true  
  belongs_to :tme_job_main 
end

class Skrscore
  include DataMapper::Resource
  storage_names[repository = :default] = 'skrscore'
  property :tme_skr_main_id, Serial, key: true, :index=>true, :field => 'skr_id'
  property :skrscore_total, Integer, :index => true, :default=>0

  belongs_to :tme_skr_main
end

class MatchedJob
  include DataMapper::Resource

  property :id, Serial, key: true, :index => true  
  property :tme_skr_main_id, Integer, :index => true, :field => 'user_id'  
  property :datematched, Date, :index => true  
  property :matchscore, Integer, :index => true  
  property :matchrank, Integer, :index => true  
  property :jobfunction, String, length:80, :index => true  
  property :joblevel, String, length:80, :index => true  
  property :jobsalaryrange, String, length:100, :index => true  

  belongs_to :tme_skr_main 
end



class CareerScore
  include DataMapper::Resource

  property :id, Serial, key: true
  property :careerscore, Integer
  property :last9careerscore, String
  property :user_id, Integer

  belongs_to :tme_skr_main
end


class Language   
  include DataMapper::Resource

  property :id, Serial , key: true, :index => true
  property :user_id, Integer, :index => true
  property :languageid, Integer, :index => true
  property :writtenrank, Integer, :index => true                  #1=Basic 2=Intermediate 3=Advance 4=Expert
  property :spokenrank, Integer, :index => true                  #1=Basic 2=Intermediate 3=Advance 4=Expert
  property :status, Integer, :default  => 2,:index => true     #0=delete, 1=edited, 2=active
  property :updated_at, DateTime                #When was it last edited

  belongs_to :user 
end

class LanguageSource                           
  include DataMapper::Resource                 

  property :id, Serial , key: true, :index => true
  property :languagename, String, length:100, :index => true        

end

class SkillSummary    
  include DataMapper::Resource
  storage_names[repository = :default] = 'tme_skr_skill'
  property :id, Serial , key: true, :index => true, :field => 'skr_skill_id'
  property :tme_skr_main_id, Integer, :index => true, :field => 'skr_id'
  property :skillid, Integer, :index => true, :field => 'skr_skill'
  property :skillrank, Integer,  :index => true, :field => 'skr_skillrank'
  # property :skillcatid, Integer, :index => true #to be removed
  property :status, Integer, :default  => 2,:index => true, :field => 'skr_skillstatus'     #0=delete, 1=edited, 2=active
  property :updated_at, DateTime, :field => 'skr_skillmod'               #When was it last edited


  belongs_to :tme_skr_main 
end

class SkillSource                               #This is for Skill Management Table.
  include DataMapper::Resource                  #Matching skills to category
  storage_names[repository = :default] = 'tme_list_skill'
  property :id, Serial , key: true, :index => true, :field => 'skill_id'
  property :skill_name, String, length:100, :index => true, :field => 'skill'      
  property :skillcategory_id, Integer, :index => true, :field => 'skillcat'
  
end

class SkillRank    
  include DataMapper::Resource
  storage_names[repository = :default] = 'tme_list_skillrank'

  property :id, Serial , key: true, :index => true, :field => 'skillrank_id'
  property :skillrankname, String, length:100, :index => true, :field => 'skillrank'   

end


class SkillCategory    
  include DataMapper::Resource
  storage_names[repository = :default] = 'tme_list_skillcat'
  property :id, Serial , key: true, :index => true, :field => 'skillcat_id'
  property :categoryname, String, length:100, :index => true, :field => 'skillcat'   

end

class TmeListLanguage    
  include DataMapper::Resource              
  storage_names[repository = :default] = 'tme_list_language'
  property :language_id, Serial , key: true
  property :language, String, length:100
  
end

class TmeListCert   
  include DataMapper::Resource              
  storage_names[repository = :default] = 'tme_list_cert'
  property :cert_id, Serial , key: true
  property :cert, String, length:100
  property :certinst_id, Integer
  
end

class TmeListCertinst   
  include DataMapper::Resource              
  storage_names[repository = :default] = 'tme_list_certinst'
  property :certinst_id, Serial , key: true
  property :certinst, String, length:100
  
end

class TmeListCompanysize   
  include DataMapper::Resource              
  storage_names[repository = :default] = 'tme_list_companysize'
  property :companysize_id, Serial , key: true
  property :companysize, String, length:300
  
end


class TmeSkrLanguage    
  include DataMapper::Resource
  storage_names[repository = :default] = 'tme_skr_language'
  property :skr_lang_id, Serial , key: true, :index => true 
  property :tme_skr_main_id, Integer, :index => true, :field => 'skr_id'
  property :skr_lang, Integer, :index => true 
  property :skr_lang_speakskill, Integer, :index => true 
  property :skr_lang_writeskill, Integer, :index => true 
  property :skr_status, Integer, :default  => 2,:index => true #0=delete, 1=edited, 2=active

  belongs_to :tme_skr_main 
end

class TmeSkrAchieve  
  include DataMapper::Resource
  storage_names[repository = :default] = 'tme_skr_achieve'
  property :skr_achieve_id, Serial , key: true, :index => true 
  property :tme_skr_main_id, Integer, :index => true, :field => 'skr_id'
  property :achievement, String,  length: 50000, :default=>"", :index => true 
  property :status, Integer, :default  => 2,:index => true #0=delete, 1=edited, 2=active
  property :updated, DateTime

  belongs_to :tme_skr_main 
end

class TmeSkrEdu  
  include DataMapper::Resource
  storage_names[repository = :default] = 'tme_skr_edu'
  property :skr_edu_id, Serial , key: true, :index => true 
  property :tme_skr_main_id, Integer, :index => true, :field => 'skr_id'
  property :skr_unititle, Integer, :index => true  #degree
  property :skr_specialty, Integer, :index => true 
  property :skr_university, Integer, :index => true 
  property :skr_honours, Integer, :index => true 
  property :skr_gpa, Integer, :index => true 
  property :skr_unistart, DateTime, :index => true 
  property :skr_uniend, DateTime, :index => true 
  property :skr_edustatus, Integer   #0=delete, 1=edited, 2=active

  belongs_to :tme_skr_main 
end

class TmeSkrEmp
  include DataMapper::Resource
  storage_names[repository = :default] = 'tme_skr_emp'
  property :skr_emp_id, Serial , key: true, :index => true 
  property :tme_skr_main_id, Integer, :index => true, :field => 'skr_id'
  property :skr_emp_company, String, :index => true  
  property :skr_emp_industry, Integer, :index => true 
  property :skr_emp_start, Date, :index => true 
  property :skr_emp_end, Date, :index => true   
  property :skr_emp_location, Integer, :index => true 
  property :skr_emp_function, Integer, :index => true 
  property :skr_emp_title, Integer, :index => true 
  property :skr_emp_actualtitle, String, :index => true 
  property :skr_emp_years, Integer, :index => true 
  property :skr_emp_desc, String, length: 100000, :index => true 
  property :skr_emp_currentjob, Boolean, :index => true 
  property :skr_empstatus, Integer #0=delete, 1=edited, 2=active
  belongs_to :tme_skr_main 
end


class TmeListUniversity  
  include DataMapper::Resource
  storage_names[repository = :default] = 'tme_list_university'
  property :university_id, Serial , key: true, :index => true 
  property :university, String, :index => true 
  property :univ_country, Integer, :index => true 
end


class TmeListTitle
  include DataMapper::Resource
  storage_names[repository = :default] = 'tme_list_title'
  property :title_id, Serial , key: true, :index => true 
  property :title, String, :index => true 

  #belongs_to :tme_job_main 
end


class TmeListFunction
  include DataMapper::Resource
  storage_names[repository = :default] = 'tme_list_function'
  property :function_id, Serial , key: true, :index => true 
  property :function, String, :index => true 
end

class TmeListDegree
  include DataMapper::Resource
  storage_names[repository = :default] = 'tme_list_degree'
  property :degree_id, Serial , key: true, :index => true 
  property :degree, String, :index => true 
end

class TmeListSpecialty
  include DataMapper::Resource
  storage_names[repository = :default] = 'tme_list_specialty'
  property :specialty_id, Serial , key: true, :index => true 
  property :specialty, String, :index => true 
end

class TmeListNeedstrength
  include DataMapper::Resource
  storage_names[repository = :default] = 'tme_list_needstrength'
  property :needstrength_id, Serial , key: true, :index => true 
  property :needstrength, String, :index => true 
end

class TmeListHonors
  include DataMapper::Resource
  storage_names[repository = :default] = 'tme_list_honors'
  property :honors_id, Serial , key: true, :index => true 
  property :honors, String, :index => true 
end

class TmeSkrNation   
  include DataMapper::Resource
  storage_names[repository = :default] = 'tme_skr_nation'
  property :skr_nation_id, Serial , key: true, :index => true 
  property :tme_skr_main_id, Integer, :index => true, :field => 'skr_id'
  property :skr_nation, Integer, :default => 197, :index => true   #197 --- 
  property :skr_nation_type, Integer, :default=> 6, :index => true #1 Citizen, 2 PR 3 PEP 4 SPASS 5 WP 6 ---

  belongs_to :tme_skr_main 
end

class NewSkillReport      #For users to report new skills that are now listed
  include DataMapper::Resource

  property :id, Serial , key: true, :index => true
  property :skillname, String, length:100, :index => true 
  property :references, String, length:5000, :index => true 
  property :user_id, Integer, :index => true 

  end

class JobIndustry     #Preferred Industry
  include DataMapper::Resource

  property :id, Serial , key: true, :index => true
  property :user_id, Integer
  property :industryid, Integer, :index => true   

belongs_to :tme_skr_main
end

class PreferredLocation      
  include DataMapper::Resource

  property :id, Serial , key: true, :index => true
  property :user_id, Integer
  property :countryid, Integer, :index => true   

belongs_to :tme_skr_main
end

class SkrscoreCerts
  include DataMapper::Resource

  property :id, Integer , key: true, :index => true
  property :certcount, Integer

end

class TmeAdmin  
 include DataMapper::Resource
 storage_names[repository = :default] = 'tme_admin'
 property :admin_id, Integer, key:true
 property :cleanup, Integer
 property :delete_emptyusers, Integer
end


# Tell DataMapper the models are done being defined
DataMapper.finalize

# Update the database to match the properties of User.
#DataMapper.auto_upgrade!
