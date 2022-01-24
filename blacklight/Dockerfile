FROM ruby:2.7.5

# Inspired by https://github.com/ualbertalib/discovery/blob/master/Dockerfile

# Updates and node install
RUN apt-get update -qq \
    && apt-get install -y build-essential \
                          nodejs \
                          vim \
                          libxml2-dev \
                          libxslt-dev \
                          sqlite3

RUN mkdir -p /app
WORKDIR /app

# Preinstall gems in an earlier layer so we don't reinstall every time any file changes.
COPY Gemfile /app
COPY Gemfile.lock /app
#RUN gem install bundler #-v 2.2.20
#RUN bundle install --jobs 20 --retry 5
RUN gem install bundler:1.17.3 && bundle install --jobs 20 --retry 5

# *NOW* we copy the codebase in
COPY . /app

# Make sure sqlite database set up
RUN rake db:migrate

# Clean environment
RUN apt-get clean all

# Precompile Rails assets.  We set a dummy database url/token key
# Only makes sense if RAILS_ENV=production
# RUN RAILS_ENV=uat SECRET_KEY_BASE=pickasecuretoken bundle exec rake assets:precompile

EXPOSE 3000

CMD foreman s -f Procfile
