# tells Dockerfile the image to use
FROM ruby:2.6

RUN apt-get update

# install packages into container
RUN apt-get install --assume-yes --no-install-recommends build-essential \
postgresql-client \
ca-certificates \
nodejs \
graphviz

# define environment variable at root directory
ENV APP /usr/src/app

# makes directory for app
RUN mkdir -p $APP
WORKDIR $APP

# copies gemfile and gemfile.lock into the app folder
COPY Gemfile* $APP/

# run bundle install on as many threads as possible (efficiency)
RUN bundle install --jobs=$(nproc)

# copy all code into app folder
COPY . $APP/

# starting rails server on port 3000
CMD ["bin/rails", "server", "-p", "3000", "-b", "0.0.0.0"]
