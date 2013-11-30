require 'rails/generators/base'

module Devise
  module Generators
    # Include this module in your generator to generate Devise views.
    # `copy_views` is the main method and by default copies all views
    # with forms.
    module ViewPathTemplates #:nodoc:
      extend ActiveSupport::Concern

      included do
        argument :scope, required: false, default: nil, desc: "The scope to copy views to"

        # Le sigh, ensure Thor won't handle opts as args
        # It should be fixed in future Rails releases
        class_option :form_builder, :aliases => "-b"
        class_option :markerb

        public_task :copy_views
      end

      # TODO: Add this to Rails itself
      module ClassMethods
        def hide!
          Rails::Generators.hide_namespace self.namespace
        end
      end

      def copy_views
        view_directory :accounts
        view_directory :bugs
        view_directory :occurrences
        view_directory :project
        view_directory :projects
        view_directory :sessions
        view_directory :users
      end

      protected

      def view_directory(name, _target_path = nil)
        directory name.to_s, _target_path || "#{target_path}/#{name}" do |content|
          content
        end
      end

      def target_path
        @target_path ||= "app/views/#{scope || :squash}"
      end
    end

    class SharedViewsGenerator < Rails::Generators::Base #:nodoc:
      include ViewPathTemplates
      source_root File.expand_path("../../../../app/views/squash", __FILE__)
      desc "Copies shared Devise views to your application."
      hide!

      # Override copy_views to just copy mailer and shared.
      def copy_views
        view_directory :shared
      end
    end

    class ErbGenerator < Rails::Generators::Base #:nodoc:
      include ViewPathTemplates
      source_root File.expand_path("../../../../app/views/squash", __FILE__)
      desc "Copies Devise mail erb views to your application."
      hide!

      def copy_views
        view_directory :mailer
      end
    end

    class ViewsGenerator < Rails::Generators::Base
      desc "Copies Devise views to your application."
      argument :scope, required: false, default: nil, desc: "The scope to copy views to"
      invoke SharedViewsGenerator
    end
  end
end