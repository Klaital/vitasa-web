# vitasa-web README
Web App app for maintaining site status for the VITA (Volunteer Income Tax Assistance) program in San Antonio.

Developed with:
* ruby 2.3
* rails 5.0.0.1
* on Ubuntu

## Setup instructions
    
    gem install bundler
    sudo apt-get install build-essential patch ruby-dev zlib1g-dev liblzma-dev libmysqlclient-dev libsqlite3-dev nodejs
    bundle install
    bundle exec rails db:setup
    bundle exec rails server
  