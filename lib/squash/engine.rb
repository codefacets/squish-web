require 'ostruct'

module Squash
  include ActiveSupport::Configurable

  # class Application # this is  essentially a hack to avoid changing as much of the squash code as possible
  #   Rails.application
  # end

  # another hack, this time for Squash::Configuration (configoro)
  class Configuration

    def self.setup_struct_from_hash(hsh)
      return OpenStruct.new(hsh)
      # new_hsh = {}
      # hsh.each_pair do |key,value|
      #   new_hsh["#{key}?".to_sym] = value if value.is_a?(Boolean)
      #   new_hsh[key] = value
      # end
      # Struct.new(*new_hsh.keys).new(*new_hsh.values)
    end

    def self.authentication
      @authentication_config ||= setup_struct_from_hash({
        strategy: 'password',
        registration_enabled: true
      })
    end

    def self.pagerduty
      @pagerduty_config ||= setup_struct_from_hash({ disabled: true })
    end

    def self.mailer
      @mailer_config ||= setup_struct_from_hash({
        from: 'squash@YOUR_DOMAIN',
        domain: 'YOUR_DOMAIN',
        host: 'localhost:3000',
        protocol: 'http'
      })
    end

    def self.javascript_dogfood
      @javascript_dogfood ||= setup_struct_from_hash(::Rails.env.production? ? { APIHost: 'YOUR_URL' } : {})
    end

    # can't we think of a better name for this?
    def self.dogfood
      @dogfood_config ||= setup_struct_from_hash({
        transmit_timeout: 60,
        ignored_exception_classes: [
          'ActionController::RoutingError',
          'ActionController::MethodNotAllowed',
          'ActionController::ActionNotFound'
        ],
        ignored_exception_messages: {
          'SignalException' => [ 'SIGTERM' ],
          'ActiveRecord::StatementInvalid' => [ 'This connection has been closed.' ]
        },
        failsafe_log: 'log/squash.failsafe.log',
        disabled: true,
        api_key: 'YOUR_PRODUCTION_SQUASH_API_KEY',
        api_host: 'YOUR_URL'
      })
    end

    def self.concurrency
      @concurrency_config ||= setup_struct_from_hash({
        background_runner: 'Sidekiq',
        multithread: {
          priority_threshold: 50,
          pool_size: 20,
          max_threads: 100,
          priority: {
            'CommentNotificationMailer'    => 80,
            'DeployFixMarker'              => 70,
            'DeployNotificationMailer'     => 80,
            'JiraStatusWorker'             => 20,
            'ObfuscationMapWorker'         => 60,
            'OccurrenceNotificationMailer' => 80,
            'OccurrencesWorker'            => 40,
            'PagerDutyAcknowledger'        => 20,
            'PagerDutyNotifier'            => 80,
            'PagerDutyResolver'            => 20,
            'ProjectRepoFetcher'           => 30,
            'SourceMapWorker'              => 60,
            'SymbolicationWorker'          => 60
          }
        },
        resque: {
          development: "localhost:6379",
          production: "localhost:6379",
          test: "localhost:6379",
          pool: { squash: 2 },
          queue: {
            'CommentNotificationMailer' => 'squash',
            'DeployFixMarker' => 'squash',
            'DeployNotificationMailer' => 'squash',
            'JiraStatusWorker' => 'squash',
            'ObfuscationMapWorker' => 'squash',
            'OccurrenceNotificationMailer' => 'squash',
            'OccurrencesWorker' => 'squash',
            'PagerDutyAcknowledger' => 'squash',
            'PagerDutyNotifier' => 'squash',
            'PagerDutyResolver' => 'squash',
            'ProjectRepoFetcher' => 'squash',
            'SourceMapWorker' => 'squash',
            'SymbolicationWorker' => 'squash'
          }
        },
        sidekiq: {
          redis: {
            url: 'redis://localhost:6379',
            namespace: 'squash',
            pidfile: './tmp/pids/sidekiq.pid',
            concurrency: 12,
            queues: [
              ['emails', 3],
              ['git', 2],
              ['occurrences', 1],
              ['processing', 3],
              ['services', 2]
            ]
          },
          worker_options: {
            'CommentNotificationMailer'    => { queue: 'emails' },
            'DeployFixMarker'              => { queue: 'processing' },
            'DeployNotificationMailer'     => { queue: 'emails' },
            'JiraStatusWorker'             => { queue: 'services' }, # retry: false },
            'ObfuscationMapWorker'         => { queue: 'processing' },
            'OccurrenceNotificationMailer' => { queue: 'emails' },
            'OccurrencesWorker'            => { queue: 'occurrences' }, # retry: false },
            'PagerDutyAcknowledger'        => { queue: 'services' },
            'PagerDutyNotifier'            => { queue: 'services' },
            'PagerDutyResolver'            => { queue: 'services' },
            'ProjectRepoFetcher'           => { queue: 'git' },
            'SourceMapWorker'              => { queue: 'processing' },
            'SymbolicationWorker'          => { queue: 'processing' }
          }
        }
      })
    end

    def self.jira
      @jira_config ||= setup_struct_from_hash({
        disabled: true,
        authentication: {
          strategy: 'basic',
          user: 'YOUR_USERNAME',
          password: 'YOUR_PASSWORD' },
        api_host: 'https://yourcompany.com',
        api_root: '/jira',
        create_issue_details: '/secure/CreateIssueDetails!init.jspa' })
    end

    def self.repositories
      Struct.new(:directory).new('tmp/repos')
    end

    # def method_missing(*args)
    #   Squash.config.send(*args)
    # end

    # def self.method_missing(*args)
    #   Squash.config.send(*args)
    # end

  end

  class Engine < ::Rails::Engine
    # isolate_namespace Squash

    def self.inject_user_concern
      config.user_model.constantize.send :include, Squash::UserAssociations
      config.user_model.constantize.send :include, Squash::UserConcern
    end

    def self.inject_user_associations
      Squash::Project.send :belongs_to, :owner, class_name: config.user_model, inverse_of: :owned_projects
      Squash::Project.send :has_many, :members, through: :memberships, source: :user, class_name: config.user_model

      Squash::Membership.send :belongs_to, :user, class_name: config.user_model
    end

    config.user_model = 'Squash::User' # override with your own
    config.to_prepare &method(:inject_user_concern).to_proc
    config.to_prepare &method(:inject_user_associations).to_proc
    config.allow_concurrency = true

    config.autoload_paths << config.root.join('app', 'models', 'additions')
    config.autoload_paths << config.root.join('app', 'models', 'observers')
    config.autoload_paths << config.root.join('app', 'controllers', 'additions')
    config.autoload_paths << config.root.join('app', 'views', 'additions')
    # config.autoload_paths << config.root.join('app', 'workers')
    config.autoload_paths << config.root.join('lib')
    config.autoload_paths << config.root.join('lib', 'workers')

    # Activate observers that should always be running.
    config.active_record.observers = :bug_observer, :comment_observer,
        :event_observer, :watch_observer, :occurrence_observer, :deploy_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Pacific Time (US & Canada)'

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    config.active_record.schema_format = :sql

    # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
    config.assets.precompile << 'flot/excanvas.js'

    # Use custom generators
    config.generators do |g|
      g.template_engine     :erector
      g.test_framework      :rspec, fixture: true, views: false
      g.integration_tool    :rspec
      g.fixture_replacement :factory_girl, dir: 'spec/factories'
    end
  end
end

require 'api/errors'