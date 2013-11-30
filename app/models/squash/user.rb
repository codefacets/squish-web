# Copyright 2013 Square Inc.
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.

require 'digest/sha2'

# A user account on this websites. Users have {Membership Memberships} to one or
# more {Project Projects}, allowing them to view and manage {Bug Bugs} in that
# project.
#
# Users can be authenticated by one of several authentication schemes. The value
# in `config/environments/common/authentication.yml` determines which of the
# authentication modules is mixed into this model.
#
# User avatars can come from people.json, or otherwise their {#gravatar}.
#
# Associations
# ============
#
# |                           |                                                                                  |
# |:--------------------------|:---------------------------------------------------------------------------------|
# | `memberships`             | The {Membership Memberships} involving this user.                                |
# | `member_projects`         | The {Project Projects} this user is a member of.                                 |
# | `owned_projects`          | The {Project Projects} this user is the owner of.                                |
# | `watches`                 | The {Watch Watches} representing Bugs this User is watching.                     |
# | `user_events`             | The denormalized {UserEvent UserEvents} from Bugs this User is watching.         |
# | `emails`                  | The blame {Email Emails} that are associated with this User.                     |
# | `notification_thresholds` | The {NotificationThreshold NotificationThresholds} this User has placed on Bugs. |
#
# Properties
# ==========
#
# |            |                                 |
# |:-----------|:--------------------------------|
# | `username` | The LDAP username of this user. |
#
# Metadata
# ========
#
# |              |                        |
# |:-------------|:-----------------------|
# | `first_name` | The user's first name. |
# | `last_name`  | The user's last name.  |

module Squash
  class User < Squash::Record
    include Squash::UserConcern
    include HasMetadataColumn
    include "#{Squash::Configuration.authentication.strategy}_authentication".camelize.constantize

    has_metadata_column(
        first_name: {length: {maximum: 100}, allow_nil: true},
        last_name:  {length: {maximum: 100}, allow_nil: true}
    )

    # @return [String] The user's full name, or as much of it as available, or the
    #   `username`.

    def name
      return username unless first_name.present? || last_name.present?
      I18n.t('models.user.name', first_name: first_name, last_name: last_name).strip
    end

    # @return [String] The user's company email address.

    def email
      @email ||= (emails.loaded? ? emails.detect(&:primary).email : emails.primary.first.email)
    end

  end
end