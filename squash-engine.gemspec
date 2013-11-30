# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'squash/version'

Gem::Specification.new do |s|
  s.name        = "squash-engine"
  s.homepage    = "http://squash.io/"
  s.summary     = "Exception reporting and bug analysis tool"
  s.description = "Exception reporting and bug analysis tool"
  s.email       = [ 'github@timothymorgan.info' ]
  s.authors     = [ 'Tim Morgan']
  s.license     = 'MIT'
  s.version     = Squash::VERSION

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # s.add_dependency 'sass-rails'
  # s.add_dependency 'libv8', platform: :mri
  # s.add_dependency 'therubyracer', '>= 0.11.1', platform: :mri
  # s.add_dependency 'therubyrhino', platform: :jruby
  # s.add_dependency 'less-rails'
  # s.add_dependency 'font-awesome-rails'
  # s.add_dependency 'coffee-rails'
  # s.add_dependency 'uglifier'
  # s.add_dependency 'jquery-rails'

  s.add_dependency 'sidekiq'
  s.add_dependency 'slim'
  s.add_dependency 'sinatra'
  s.add_dependency 'squash_ruby', '>= 1.2.0'
  s.add_dependency 'squash_rails'
  s.add_dependency 'squash_ios_symbolicator'
  s.add_dependency 'squash_javascript'
  s.add_dependency 'squash_java'
  s.add_dependency 'rails', '>= 4.0.0'
  s.add_dependency 'configoro', '>= 1.2.4'
  s.add_dependency 'rack-cors'
  s.add_dependency 'jira-ruby'
  s.add_dependency 'pg'
  # s.add_dependency 'activerecord-jdbcpostgresql-adapter'
  s.add_dependency 'has_metadata_column'
  s.add_dependency 'slugalicious'
  s.add_dependency 'email_validation'
  s.add_dependency 'email_validator'
  s.add_dependency 'url_validation'
  s.add_dependency 'json_serialize'
  s.add_dependency 'validates_timeliness'
  s.add_dependency 'find_or_create_on_scopes', '>= 1.2.1'
  s.add_dependency 'composite_primary_keys'
  s.add_dependency 'rails-observers'
  s.add_dependency 'activerecord-postgresql-cursors'
  s.add_dependency 'json'
  s.add_dependency 'git'
  s.add_dependency 'user-agent'
  s.add_dependency 'safe_yaml'
  # s.add_dependency 'erector'
  s.add_dependency 'kramdown'
  s.add_dependency 'yard'

  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'factory_girl_rails'
  s.add_development_dependency 'fakeweb'
  # s.add_development_dependency 'yard' # moved up to regular dependency
  s.add_development_dependency 'redcarpet'
  s.add_development_dependency 'json-schema', '< 2.0.0' # version 2.0 breaks fdoc
  s.add_development_dependency 'fdoc'
  s.add_development_dependency 'sql_origin'
end