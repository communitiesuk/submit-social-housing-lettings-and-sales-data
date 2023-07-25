FROM ruby:3.1.4-alpine3.18 as base

WORKDIR /app

# Add the timezone as it’s not configured by default in Alpine
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
RUN bundle install --jobs=4 --no-binstubs --no-cache

COPY package.json yarn.lock /app/
RUN yarn install --frozen-lockfile

COPY . /app/

RUN bundle exec rake assets:precompile

ENV PORT=8080

EXPOSE ${PORT}

FROM base as development

# Install gecko driver for Capybara tests
RUN apk add firefox
RUN wget https://github.com/mozilla/geckodriver/releases/download/v0.31.0/geckodriver-v0.31.0-linux64.tar.gz \
  && tar -xvzf geckodriver-v0.31.0-linux64.tar.gz \
  && rm geckodriver-v0.31.0-linux64.tar.gz \
  && chmod +x geckodriver \
  && mv geckodriver /usr/local/bin/

CMD RAILS_ENV=${RAILS_ENV} bundle exec rake db:migrate && bundle exec rails s -e ${RAILS_ENV} -p ${PORT} --binding=0.0.0.0

FROM base as staging

CMD RAILS_ENV=${RAILS_ENV} bundle exec rake db:migrate && bundle exec rails s -e ${RAILS_ENV} -p ${PORT} --binding=0.0.0.0

FROM base as production

CMD RAILS_ENV=${RAILS_ENV} bundle exec rake db:migrate && bundle exec rails s -e ${RAILS_ENV} -p ${PORT} --binding=0.0.0.0
