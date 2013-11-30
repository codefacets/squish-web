module Squash
  module UserAssociations
    extend ActiveSupport::Concern

    included do
      has_many :assigned_bugs, dependent: :nullify, inverse_of: :assigned_user, class_name: 'Squash::Bug', foreign_key: 'assigned_user_id'
      has_many :owned_projects, dependent: :restrict_with_exception, class_name: 'Squash::Project', foreign_key: 'owner_id', inverse_of: :owner
      has_many :comments, class_name: 'Squash::Comment', dependent: :nullify, inverse_of: :user
      has_many :events, class_name: 'Squash::Event', dependent: :nullify, inverse_of: :user
      has_many :memberships, class_name: 'Squash::Membership', dependent: :delete_all, inverse_of: :user
      has_many :watches, class_name: 'Squash::Watch', dependent: :delete_all, inverse_of: :user
      has_many :user_events, class_name: 'Squash::UserEvent', dependent: :delete_all, inverse_of: :user
      has_many :emails, class_name: 'Squash::Email', dependent: :delete_all, inverse_of: :user
      has_many :notification_thresholds, class_name: 'Squash::NotificationThreshold', dependent: :delete_all, inverse_of: :user
      has_many :member_projects, class_name: 'Squash::Project', through: :memberships, source: :project
    end
  end
end