FROM ruby:3.1.6-alpine3.20 as base

WORKDIR /app

# Add the timezone as it's not configured by default in Alpine
RUN apk add --update --no-cache tzdata && \
    cp /usr/share/zoneinfo/Europe/London /etc/localtime && \
    echo "Europe/London" > /etc/timezone

# build-base: compilation tools for bundle
# yarn: node package manager
# postgresql-dev: postgres driver and libraries
RUN apk add --no-cache build-base=0.5-r3 busybox=1.36.1-r29 nodejs=20.15.1-r0 yarn=1.22.22-r0 bash=5.2.26-r0 libpq-dev

# Bundler version should be the same version as what the Gemfile.lock was bundled with
RUN gem install bundler:2.6.4 --no-document

COPY .ruby-version Gemfile Gemfile.lock /app/
RUN bundle config set without "development test"
RUN bundle install --jobs=4 --no-binstubs --no-cache

COPY package.json yarn.lock /app/
RUN yarn install --frozen-lockfile

COPY . /app/

RUN bundle exec rake assets:precompile

ENV PORT=8080
EXPOSE ${PORT}

RUN adduser --system --no-create-home nonroot

RUN apk add curl
RUN apk add apache2-utils

FROM base as test

RUN bundle config set without ""
RUN bundle install --jobs=4 --no-binstubs --no-cache

# Install gecko driver for Capybara tests
RUN apk add firefox
RUN wget https://github.com/mozilla/geckodriver/releases/download/v0.31.0/geckodriver-v0.31.0-linux64.tar.gz \
    && tar -xvzf geckodriver-v0.31.0-linux64.tar.gz \
    && rm geckodriver-v0.31.0-linux64.tar.gz \
    && chmod +x geckodriver \
    && mv geckodriver /usr/local/bin/

CMD bundle exec rake parallel:setup && bundle exec rake parallel:spec

FROM base as development

# We expect the rake assets:precompile command to create these directories, but mkdir -p will create them if they don't already exist
RUN mkdir -p tmp log
RUN chown -R nonroot tmp log
RUN chown nonroot db/schema.rb

RUN bundle config set without "test"
RUN bundle install --jobs=4 --no-binstubs --no-cache

USER nonroot

CMD bundle exec rails s -e ${RAILS_ENV} -p ${PORT} --binding=0.0.0.0

FROM base as production

# We expect the rake assets:precompile command to create these directories, but mkdir -p will create them if they don't already exist
RUN mkdir -p tmp log
RUN chown -R nonroot tmp log
RUN chown nonroot db/schema.rb

RUN mkdir -p performance_test
RUN chown -R nonroot performance_test

USER nonroot

CMD bundle exec rails s -e ${RAILS_ENV} -p ${PORT} --binding=0.0.0.0
