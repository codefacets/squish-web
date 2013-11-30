module Squash
  module UserConcern
    extend ActiveSupport::Concern

    # included do
    #   attr_readonly :username
    #
    #   class_attribute :people_json
    #
    #   validates :username,
    #             presence:   true,
    #             length:     {maximum: 50},
    #             format:     {with: /\A[a-z0-9_\-]+\z/},
    #             uniqueness: true, if: Proc.new { |m| m.respond_to?(:username) }
    #
    #   before_validation on: :create do |obj|
    #     obj.email    = obj.email.downcase    if obj.respond_to?(:username)
    #     obj.username = obj.username.downcase if obj.respond_to?(:username) && obj.username
    #   end
    #
    #   after_create :create_primary_email
    #
    #   set_nil_if_blank :first_name, :last_name
    #
    #   scope :prefix, ->(query) { where("LOWER(username) LIKE ?", query.downcase.gsub(/[^a-z0-9\-_]/, '') + '%') }
    # end

    included do
      scope :prefix, ->(query) { where("LOWER(username) LIKE ?", query.downcase.gsub(/[^a-z0-9\-_]/, '') + '%') }
    end

    # @return [String] The URL to the user's Gravatar.

    def gravatar
      "http://www.gravatar.com/avatar/#{Digest::MD5.hexdigest email}"
    end

    # Returns a symbol describing a user's role in relation to a model object;
    # used for strong attribute roles.
    #
    # @param [ActiveRecord::Base] object A model instance.
    # @return [Symbol, nil] The user's role, or `nil` if the user has no
    #   permissions. Possible values are `:creator`, `:owner`, `:admin`,
    #   `:member`, and `nil`.

    def role(object)
      object = object.environment.project if object.kind_of?(Bug)

      case object
        when Project
          return :owner if object.owner_id == id
          membership = memberships.where(project_id: object.id).first
          return nil unless membership
          return :admin if membership.admin?
          return :member
        when Comment
          return :creator if object.user_id == id
          return :owner if object.bug.environment.project.owner_id == id
          membership = memberships.where(project_id: object.bug.environment.project_id).first
          return :admin if membership.try!(:admin?)
          return nil
        else
          return nil
      end
    end

    # Returns whether or not a User is watching a {Bug}.
    #
    # @param [Bug] bug A Bug.
    # @return [Watch, false] Whether or not the User is watching that Bug.
    # @see Watch

    def watches?(bug)
      watches.where(bug_id: bug.id).first
    end

    # @private
    # def to_param() username end

    def as_json(options=nil)
      puts "~~~>> KLELL!!! as_json IN DA USER CONCERNIO!!"
      options ||= {}

      options[:except] = Array.wrap(options[:except])
      options[:except] << :id
      options[:except] << :updated_at

      options[:methods] = Array.wrap(options[:methods])
      options[:methods] << :name
      options[:methods] << :email
      options[:methods] << :gravatar

      puts "~~~>> KLELL!!! DAHH!! GONNA SEND SUPER BROSEF!!"
      super options
    end

    # @private
    def to_json(options={})
      options[:except] = Array.wrap(options[:except])
      options[:except] << :id
      options[:except] << :updated_at

      options[:methods] = Array.wrap(options[:methods])
      options[:methods] << :name
      options[:methods] << :email

      super options
    end

  end
end