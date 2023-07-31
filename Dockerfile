FROM ruby:3.1.4-alpine3.18 as base

WORKDIR /app

# Add the timezone as it's not configured by default in Alpine
RUN apk add --update --no-cache tzdata && \
    cp /usr/share/zoneinfo/Europe/London /etc/localtime && \
    echo "Europe/London" > /etc/timezone

# build-base: compilation tools for bundle
# yarn: node package manager
# postgresql-dev: postgres driver and libraries
RUN apk add --no-cache build-base yarn postgresql-dev git bash

# Bundler version should be the same version as what the Gemfile.lock was bundled with
RUN gem install bundler:2.3.14 --no-document

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

# We expect the rake assets:precompile command to create these directories, but mkdir -p will create them if they don't already exist
RUN mkdir -p tmp log
RUN chown -R nonroot tmp log
RUN chown nonroot db/schema.rb

FROM base as development

RUN bundle config set without ""
RUN bundle install --jobs=4 --no-binstubs --no-cache

# Install gecko driver for Capybara tests
RUN apk add firefox
RUN wget https://github.com/mozilla/geckodriver/releases/download/v0.31.0/geckodriver-v0.31.0-linux64.tar.gz \
    && tar -xvzf geckodriver-v0.31.0-linux64.tar.gz \
    && rm geckodriver-v0.31.0-linux64.tar.gz \
    && chmod +x geckodriver \
    && mv geckodriver /usr/local/bin/

USER nonroot

CMD bundle exec rails s -e ${RAILS_ENV} -p ${PORT} --binding=0.0.0.0

FROM base as staging

RUN bundle config set without "development"
RUN bundle install --jobs=4 --no-binstubs --no-cache

# Cleanup to reduce image size
RUN rm -rf node_modules && \
    rm -rf /usr/local/bundle/cache && \
    find /usr/local/bundle/gems -name "*.c" -delete && \
    find /usr/local/bundle/gems -name "*.h" -delete && \
    find /usr/local/bundle/gems -name "*.o" -delete && \
    find /usr/local/bundle/gems -name "*.html" -delete && \
    rm -rf .env  && \
    rm -rf app/frontend

USER nonroot

CMD bundle exec rails s -e ${RAILS_ENV} -p ${PORT} --binding=0.0.0.0

FROM base as production

# Cleanup to reduce image size
RUN rm -rf node_modules && \
    rm -rf /usr/local/bundle/cache && \
    find /usr/local/bundle/gems -name "*.c" -delete && \
    find /usr/local/bundle/gems -name "*.h" -delete && \
    find /usr/local/bundle/gems -name "*.o" -delete && \
    find /usr/local/bundle/gems -name "*.html" -delete && \
    rm -rf .env  && \
    rm -rf app/frontend

USER nonroot

CMD bundle exec rails s -e ${RAILS_ENV} -p ${PORT} --binding=0.0.0.0
