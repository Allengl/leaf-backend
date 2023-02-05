
FROM ruby:3.0.0
ENV RAILS_ENV production
RUN mkdir /leaf
RUN bundle config mirror.https://rubygems.org https://gems.ruby-china.com
WORKDIR /leaf
ADD Gemfile /leaf
ADD Gemfile.lock /leaf
ADD vendor/cache /leaf/vendor/cache
RUN bundle config set --local without 'development test'
RUN bundle install --local

ADD leaf-*.tar.gz ./
ENTRYPOINT bundle exec puma
