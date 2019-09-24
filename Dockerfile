FROM ruby:2.6
RUN apt-get update -qq && apt-get install -y nodejs

RUN mkdir /vitasa
WORKDIR /vitasa

RUN gem install bundler
COPY Gemfile /vitasa/Gemfile
COPY Gemfile.lock /vitasa/Gemfile.lock
RUN bundle install

COPY . /vitasa/
RUN bundle exec rails assets:precompile

# Startup script to auto-migrate the database
COPY run/wait-for-it.sh /vitasa/
RUN chmod +x /vitasa/entrypoint.sh
RUN chmod +x /vitasa/wait-for-it.sh

EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]
