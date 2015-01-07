GEM
  remote: https://rubygems.org/
  specs:
    actionpack (4.1.4)
      actionview (= 4.1.4)
      activesupport (= 4.1.4)
      rack (~> 1.5.2)
      rack-test (~> 0.6.2)
    actionview (4.1.4)
      activesupport (= 4.1.4)
      builder (~> 3.1)
      erubis (~> 2.7.0)
    activesupport (4.1.4)
      i18n (~> 0.6, >= 0.6.9)
      json (~> 1.7, >= 1.7.7)
      minitest (~> 5.1)
      thread_safe (~> 0.1)
      tzinfo (~> 1.1)
    autoprefixer-rails (2.1.0.20140628)
      execjs
    backports (3.6.0)
    bootstrap-sass (3.1.0.2)
      sass (~> 3.2)
    builder (3.2.2)
    coffee-script (2.2.0)
      coffee-script-source
      execjs
    coffee-script-source (1.7.0)
    daemon_controller (1.2.0)
    daemons (1.1.9)
    dashing (1.3.2)
      coffee-script (>= 1.6.2)
      execjs (>= 2.0.0)
      rack
      rufus-scheduler (~> 2.0)
      sass
      sinatra
      sinatra-contrib
      sprockets
      thin
      thor
    erubis (2.7.0)
    eventmachine (1.0.3)
    execjs (2.2.1)
    hike (1.2.3)
    httparty (0.13.1)
      json (~> 1.8)
      multi_xml (>= 0.5.2)
    i18n (0.6.11)
    json (1.8.1)
    mini_portile (0.6.0)
    minitest (5.4.0)
    multi_json (1.10.1)
    multi_xml (0.5.5)
    nokogiri (1.6.2.1)
      mini_portile (= 0.6.0)
    passenger (4.0.45)
      daemon_controller (>= 1.2.0)
      rack
      rake (>= 0.8.1)
    rack (1.5.2)
    rack-protection (1.5.3)
      rack
    rack-test (0.6.2)
      rack (>= 1.0)
    railties (4.1.4)
      actionpack (= 4.1.4)
      activesupport (= 4.1.4)
      rake (>= 0.8.7)
      thor (>= 0.18.1, < 2.0)
    rake (10.3.2)
    roo (1.13.2)
      nokogiri
      rubyzip
      spreadsheet (> 0.6.4)
    ruby-ole (1.2.11.7)
    rubyzip (1.1.6)
    rufus-scheduler (2.0.24)
      tzinfo (>= 0.3.22)
    sass (3.2.19)
    sass-rails (4.0.3)
      railties (>= 4.0.0, < 5.0)
      sass (~> 3.2.0)
      sprockets (~> 2.8, <= 2.11.0)
      sprockets-rails (~> 2.0)
    sinatra (1.4.5)
      rack (~> 1.4)
      rack-protection (~> 1.4)
      tilt (~> 1.3, >= 1.3.4)
    sinatra-contrib (1.4.2)
      backports (>= 2.0)
      multi_json
      rack-protection
      rack-test
      sinatra (~> 1.4.0)
      tilt (~> 1.3)
    spreadsheet (0.9.7)
      ruby-ole (>= 1.0)
    sprockets (2.11.0)
      hike (~> 1.2)
      multi_json (~> 1.0)
      rack (~> 1.0)
      tilt (~> 1.1, != 1.3.0)
    sprockets-rails (2.1.3)
      actionpack (>= 3.0)
      activesupport (>= 3.0)
      sprockets (~> 2.8)
    thin (1.6.2)
      daemons (>= 1.0.9)
      eventmachine (>= 1.0.0)
      rack (>= 1.0.0)
    thor (0.19.1)
    thread_safe (0.3.4)
    tilt (1.4.1)
    tzinfo (1.2.1)
      thread_safe (~> 0.1)

PLATFORMS
  ruby

DEPENDENCIES
  autoprefixer-rails
  bootstrap-sass (~> 3.1.0.2)
  dashing
  httparty
  json
  passenger
  roo
  sass-rails (>= 3.2)
