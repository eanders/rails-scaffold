# syntax = docker/dockerfile:1-experimental
# check=error=true

###########################################
## Dependencies just needed during build ##
###########################################
ARG BUILD_TAG
FROM ruby:${BUILD_TAG} AS cert

RUN apk add --no-cache \
  openssl

WORKDIR /

RUN openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 \
  -subj "/C=US/ST=Vermont/L=Brattleboro/O=greenriver/CN=www.example.com" \
  -keyout key.pem -out cert.pem


#########################
## global dependencies ##
#########################

ARG BUILD_TAG
FROM ruby:${BUILD_TAG} AS base
ARG USER_ID=10000
ARG GROUP_ID=10000
ARG BUNDLER_VERSION=${BUNDLER_VERSION}

LABEL "app"=${APP_NAME}
LABEL "ruby-version"=${RUBY_VERSION}

ENV LANG=C.UTF-8
ENV GEM_HOME=/bundle
ENV BUNDLE_JOBS=4
ENV BUNDLE_RETRY=3
ENV BUNDLE_PATH $GEM_HOME
ENV BUNDLE_APP_CONFIG=$BUNDLE_PATH
ENV BUNDLE_BIN=$BUNDLE_PATH/bin
ENV PATH /app/bin:$BUNDLE_BIN:$PATH
ENV RAILS_LOG_TO_STDOUT=true
ENV RAILS_SERVE_STATIC_FILES=true
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8

# Allow tls connection to database with verification
COPY docker/app/us-east-1-bundle.pem  /etc/ssl/certs/us-east-1-bundle.pem

# RUN export LC_ALL=en_US.UTF-8
# RUN export LANG=en_US.UTF-8

RUN groupadd -g ${GROUP_ID} app-user \
  && useradd -u ${USER_ID} -g app-user -d /home/app-user -m app-user \
  && mkdir /app /bundle \
  && chown app-user:app-user /bundle /app

COPY docker/app/dependencies.txt /tmp/dependencies.txt

RUN apt-get update -qq \
  && apt-get upgrade \
  && apt-get -y install $(cat /tmp/dependencies.txt)\
  && rm -rf /var/lib/apt/lists /var/cache/apt/archives

WORKDIR /app

RUN gem update --system \
  && gem install bundler --version=${BUNDLER_VERSION} \
  && bundle config set --local path /bundle \
  && chown -R app-user:app-user /bundle \
  && echo 'America/New_York' > /etc/timezone \
  && chmod a+w /etc/timezone

USER ${USER_ID}

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]

#########################################
## Stage/target for use in development ##
#########################################

FROM base AS dev-build

USER root

COPY docker/app/entrypoint.dev.sh /usr/bin/

ENTRYPOINT ["/usr/bin/entrypoint.dev.sh"]

RUN git config --global --add safe.directory /app \
  && apt-get update \
  && apt-get -y install \
  neovim less docker python3 zsh \
  && rm -rf /var/lib/apt/lists /var/cache/apt/archives

USER ${USER_ID}
