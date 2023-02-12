
FROM ruby:3.0.0

ENV RAILS_ENV production
RUN mkdir /leaf
RUN bundle config mirror.https://rubygems.org https://gems.ruby-china.com
WORKDIR /leaf
ADD Gemfile /leaf
ADD Gemfile.lock /leaf
ADD vendor/cache.tar.gz /leaf/vendor/
ADD vendor/rspec_api_documentation.tar.gz /leaf/vendor/ 
RUN bundle config set --local without 'development test'
RUN bundle install --local

ADD leaf-*.tar.gz ./
ENTRYPOINT bundle exec puma
