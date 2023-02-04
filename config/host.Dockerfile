FROM ruby:3.0.0

ENV RAILS_ENV production
RUN mkdir /leaf
RUN bundle config mirror.https://rubygems.org https://gems.ruby-china.com
WORKDIR /leaf
ADD leaf-*.tar.gz ./
RUN bundle config set --local without 'development test'
RUN bundle install
ENTRYPOINT bundle exec puma
