FROM ruby:2.6
RUN apt update -qq && apt install -y nodejs 

RUN mkdir /vitasa
WORKDIR /vitasa

RUN gem install bundler
COPY Gemfile /vitasa/Gemfile
COPY Gemfile.lock /vitasa/Gemfile.lock
RUN bundle install

COPY . /vitasa/

# Startup script to auto-migrate the database
COPY entrypoint.sh /vitasa/
RUN chmod +x /vitasa/entrypoint.sh
ENTRYPOINT ["/vitasa/entrypoint.sh"]

EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]
