FROM ruby:4.0.9-slim-trixie

# Inspired by https://github.com/ualbertalib/discovery/blob/master/Dockerfile

RUN apt-get update -qq \
    && apt-get install -y --no-install-recommends build-essential \
                                                  libyaml-dev \
                                                  sqlite3 \
                                                  vim \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /app
WORKDIR /app

# Preinstall gems in an earlier layer so we don't reinstall every time any file changes.
COPY Gemfile /app
COPY Gemfile.lock /app
RUN bundle install --jobs 20 --retry 5

# *NOW* we copy the codebase in
COPY . /app

# Make sure sqlite database set up
RUN bin/rails db:prepare

EXPOSE 3000

CMD foreman s -f Procfile
