# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20130222055524) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "blames", force: true do |t|
    t.string   "repository_hash", limit: 40, null: false
    t.string   "revision",        limit: 40, null: false
    t.string   "file",                       null: false
    t.integer  "line",                       null: false
    t.string   "blamed_revision", limit: 40, null: false
    t.datetime "updated_at"
  end

  add_index "blames", ["repository_hash", "revision", "file", "line"], name: "blames_key", unique: true, using: :btree
  add_index "blames", ["updated_at"], name: "blames_lru", using: :btree

  create_table "bugs", force: true do |t|
    t.integer  "assigned_user_id"
    t.string   "blamed_revision",        limit: 40
    t.string   "class_name",             limit: 128,                 null: false
    t.string   "client",                 limit: 32,                  null: false
    t.integer  "comments_count",                     default: 0,     null: false
    t.integer  "deploy_id"
    t.integer  "duplicate_of_id"
    t.integer  "environment_id",                                     null: false
    t.integer  "events_count",                       default: 0,     null: false
    t.string   "file",                                               null: false
    t.datetime "first_occurrence"
    t.boolean  "fixed",                              default: false, null: false
    t.boolean  "fix_deployed",                       default: false, null: false
    t.boolean  "irrelevant",                         default: false, null: false
    t.datetime "latest_occurrence"
    t.integer  "line",                                               null: false
    t.text     "metadata"
    t.integer  "number"
    t.integer  "occurrences_count",                  default: 0,     null: false
    t.string   "resolution_revision",    limit: 40
    t.string   "revision",               limit: 40,                  null: false
    t.tsvector "searchable_text"
    t.boolean  "any_occurrence_crashed",             default: false, null: false
  end

  add_index "bugs", ["assigned_user_id", "fixed", "irrelevant"], name: "bugs_user", using: :btree
  add_index "bugs", ["assigned_user_id", "latest_occurrence", "number"], name: "bugs_user_recency", using: :btree
  add_index "bugs", ["environment_id", "assigned_user_id", "fixed", "irrelevant"], name: "bugs_env_user", using: :btree
  add_index "bugs", ["environment_id", "class_name", "file", "line", "blamed_revision", "deploy_id"], name: "bugs_find_for_occ1", using: :btree
  add_index "bugs", ["environment_id", "class_name", "file", "line", "blamed_revision", "fixed"], name: "bugs_find_for_occ2", using: :btree
  add_index "bugs", ["environment_id", "deploy_id", "assigned_user_id", "fixed", "irrelevant", "any_occurrence_crashed", "first_occurrence", "number"], name: "bugs_list_fo", using: :btree
  add_index "bugs", ["environment_id", "deploy_id", "assigned_user_id", "fixed", "irrelevant", "any_occurrence_crashed", "latest_occurrence", "number"], name: "bugs_list_lo", using: :btree
  add_index "bugs", ["environment_id", "deploy_id", "assigned_user_id", "fixed", "irrelevant", "any_occurrence_crashed", "occurrences_count", "number"], name: "bugs_list_oc", using: :btree
  add_index "bugs", ["environment_id", "number"], name: "bugs_env_number", unique: true, using: :btree
  add_index "bugs", ["fixed"], name: "bugs_fixed", using: :btree
  add_index "bugs", ["searchable_text"], name: "bugs_environment_textsearch", using: :gin

  create_table "comments", force: true do |t|
    t.integer  "bug_id",     null: false
    t.datetime "created_at", null: false
    t.text     "metadata"
    t.integer  "number"
    t.datetime "updated_at", null: false
    t.integer  "user_id"
  end

  add_index "comments", ["bug_id", "created_at"], name: "comments_bug", using: :btree
  add_index "comments", ["bug_id", "number"], name: "comments_number", unique: true, using: :btree

  create_table "deploys", force: true do |t|
    t.string   "build",          limit: 40
    t.datetime "deployed_at",                null: false
    t.integer  "environment_id",             null: false
    t.string   "hostname",       limit: 126
    t.string   "revision",       limit: 40,  null: false
    t.string   "version",        limit: 126
  end

  add_index "deploys", ["environment_id", "build"], name: "deploys_env_build", unique: true, using: :btree
  add_index "deploys", ["environment_id", "deployed_at"], name: "deploys_env_time", using: :btree
  add_index "deploys", ["environment_id", "revision", "deployed_at"], name: "deploys_env_revision", using: :btree

  create_table "device_bugs", id: false, force: true do |t|
    t.integer "bug_id",                null: false
    t.string  "device_id", limit: 126, null: false
  end

  create_table "emails", force: true do |t|
    t.boolean "primary",    default: false, null: false
    t.string  "email",                      null: false
    t.integer "project_id"
    t.integer "user_id",                    null: false
  end

  add_index "emails", ["project_id", "user_id"], name: "emails_email_user", unique: true, using: :btree
  add_index "emails", ["user_id", "primary"], name: "emails_primary", using: :btree

  create_table "environments", force: true do |t|
    t.integer "bugs_count",             default: 0, null: false
    t.string  "name",       limit: 100,             null: false
    t.integer "project_id",                         null: false
    t.text    "metadata"
  end

  add_index "environments", ["project_id"], name: "environments_name", unique: true, using: :btree

  create_table "events", force: true do |t|
    t.integer  "bug_id",                null: false
    t.datetime "created_at",            null: false
    t.text     "data"
    t.string   "kind",       limit: 32, null: false
    t.integer  "user_id"
  end

  add_index "events", ["bug_id", "created_at"], name: "events_bug", using: :btree

  create_table "memberships", id: false, force: true do |t|
    t.integer  "project_id",                 null: false
    t.integer  "user_id",                    null: false
    t.boolean  "admin",      default: false, null: false
    t.datetime "created_at",                 null: false
    t.text     "metadata"
  end

  create_table "notification_thresholds", id: false, force: true do |t|
    t.integer  "bug_id",          null: false
    t.integer  "user_id",         null: false
    t.datetime "last_tripped_at"
    t.integer  "period",          null: false
    t.integer  "threshold",       null: false
  end

  create_table "obfuscation_maps", force: true do |t|
    t.integer "deploy_id", null: false
    t.text    "namespace"
  end

  create_table "occurrences", force: true do |t|
    t.integer  "bug_id",                                        null: false
    t.string   "client",             limit: 32,                 null: false
    t.text     "metadata"
    t.integer  "number"
    t.datetime "occurred_at",                                   null: false
    t.integer  "redirect_target_id"
    t.string   "revision",           limit: 40,                 null: false
    t.uuid     "symbolication_id"
    t.boolean  "crashed",                       default: false, null: false
  end

  add_index "occurrences", ["bug_id", "number"], name: "occurrences_number", unique: true, using: :btree
  add_index "occurrences", ["bug_id", "occurred_at"], name: "occurrences_bug", using: :btree
  add_index "occurrences", ["bug_id", "redirect_target_id"], name: "occurrences_bug_redirect", using: :btree
  add_index "occurrences", ["bug_id", "revision", "occurred_at"], name: "occurrences_bug_revision", using: :btree

  create_table "projects", force: true do |t|
    t.string   "api_key",                limit: 36,  null: false
    t.datetime "created_at",                         null: false
    t.integer  "default_environment_id"
    t.text     "metadata"
    t.string   "name",                   limit: 126, null: false
    t.integer  "owner_id",                           null: false
    t.string   "repository_url",                     null: false
    t.datetime "updated_at",                         null: false
  end

  add_index "projects", ["api_key"], name: "projects_api_key_key", unique: true, using: :btree
  add_index "projects", ["owner_id"], name: "projects_owner", using: :btree

  create_table "slugs", force: true do |t|
    t.boolean  "active",                     default: true, null: false
    t.datetime "created_at",                                null: false
    t.string   "scope",          limit: 126
    t.string   "slug",           limit: 126,                null: false
    t.integer  "sluggable_id",                              null: false
    t.string   "sluggable_type", limit: 32,                 null: false
  end

  add_index "slugs", ["sluggable_type", "sluggable_id", "active"], name: "slugs_for_record", using: :btree
  add_index "slugs", ["sluggable_type"], name: "slugs_unique", unique: true, using: :btree

  create_table "source_maps", force: true do |t|
    t.integer "environment_id",            null: false
    t.text    "map"
    t.string  "revision",       limit: 40, null: false
  end

  add_index "source_maps", ["environment_id", "revision"], name: "source_maps_env_revision", using: :btree

  create_table "symbolications", id: false, force: true do |t|
    t.uuid "uuid",    null: false
    t.text "lines"
    t.text "symbols"
  end

  create_table "user_events", id: false, force: true do |t|
    t.integer  "event_id",   null: false
    t.integer  "user_id",    null: false
    t.datetime "created_at"
  end

  add_index "user_events", ["event_id", "created_at"], name: "user_events_time", using: :btree

  create_table "users", force: true do |t|
    t.datetime "created_at",            null: false
    t.text     "metadata"
    t.datetime "updated_at",            null: false
    t.string   "username",   limit: 50, null: false
  end

  create_table "watches", id: false, force: true do |t|
    t.integer  "bug_id",     null: false
    t.integer  "user_id",    null: false
    t.datetime "created_at"
  end

end
