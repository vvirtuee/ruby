# syntax = docker/dockerfile:1

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version and Gemfile
ARG RUBY_VERSION=3.2.2
FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim as base

# Rails app lives here
WORKDIR /rails

# Set production environment
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development"


# Throw-away build stage to reduce size of final image
FROM base as build

# Install packages needed to build gems
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libvips pkg-config

# Install application gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile


# Final stage for app image
FROM base

# Install packages needed for deployment
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libsqlite3-0 libvips && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Copy built artifacts: gems, application
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

# Run and own only the runtime files as a non-root user for security
RUN useradd rails --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER rails:rails

# Entrypoint prepares the database.
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Start the server by default, this can be overwritten at runtime
EXPOSE 3000
CMD ["./bin/rails", "server"]

# Tells Docker image to use
FROM ruby:3.2.2

# Update repo listings in the container
RUN apt-get update

# Install packages into container
RUN apt-get install --assume-yes --no-install-recommends build-essential postgresql-client ca-certificates nodejs

# Environment variable for app source
ENV APP /usr/src/app

# Creates directory for the app with $APP environment variable
RUN mkdir -p $APP

# Tells container where we're working from (work directory)
WORKDIR $APP

# Copies gemfile and gemfile.lock into the app folder.
COPY Gemfile* $APP/

# Tells Docker to run bundle install on as many threads available (num processes nproc)
RUN bundle install --jobs=$(nproc)

# Copy everything into the app folder
COPY . $APP/

# Tells container to create DB
CMD ["bin/rails", "db:create"]

# Tells container to run migrations
CMD ["bin/rails", "db:migrate"]

# Tells container to start a server on port 3000
CMD ["bin/rails", "server", "-p", "3000", "-b", "0.0.0.0"]
