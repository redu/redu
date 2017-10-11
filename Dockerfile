FROM ruby:1.9.3
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
RUN apt-get install -y default-jre
RUN mkdir /app
WORKDIR /app
ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app/Gemfile.lock
RUN bundle install
ADD . /app
CMD rm -f /app/tmp/pids/server.pid && bundle exec rake sunspot:solr:start && bundle exec rails s -p 3000 -b '0.0.0.0'
