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

ActiveRecord::Schema.define(version: 20171027085103) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pg_stat_statements"

  create_table "comments", force: :cascade do |t|
    t.integer  "github_id",         null: false
    t.integer  "pull_request_id",   null: false
    t.integer  "user_id"
    t.datetime "github_updated_at", null: false
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "comments", ["created_at"], name: "index_comments_on_created_at", using: :btree
  add_index "comments", ["github_id"], name: "index_comments_on_github_id", using: :btree
  add_index "comments", ["pull_request_id"], name: "index_comments_on_pull_request_id", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "organisation_user_scores", force: :cascade do |t|
    t.date     "date",                                  null: false
    t.integer  "user_id",                               null: false
    t.integer  "organisation_id",                       null: false
    t.integer  "points",                    default: 0, null: false
    t.integer  "pull_request_count",        default: 0, null: false
    t.integer  "pull_request_merge_time"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.integer  "pull_request_merge_stddev"
    t.integer  "other_merges",              default: 0, null: false
    t.integer  "comment_count",             default: 0, null: false
    t.integer  "self_comment_count",        default: 0, null: false
    t.integer  "other_comment_count",       default: 0, null: false
    t.integer  "cross_team_comment_count",  default: 0, null: false
  end

  add_index "organisation_user_scores", ["date", "user_id", "organisation_id"], name: "organisation_user_scores_on_date_user_org", unique: true, using: :btree
  add_index "organisation_user_scores", ["organisation_id"], name: "index_organisation_user_scores_on_organisation_id", using: :btree
  add_index "organisation_user_scores", ["user_id"], name: "index_organisation_user_scores_on_user_id", using: :btree

  create_table "organisation_users", force: :cascade do |t|
    t.integer  "organisation_id",             null: false
    t.integer  "user_id",                     null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "role",            default: 1, null: false
    t.string   "email"
  end

  add_index "organisation_users", ["organisation_id", "user_id"], name: "index_organisation_users_on_organisation_id_and_user_id", unique: true, using: :btree
  add_index "organisation_users", ["organisation_id"], name: "index_organisation_users_on_organisation_id", using: :btree
  add_index "organisation_users", ["user_id"], name: "index_organisation_users_on_user_id", using: :btree

  create_table "organisations", force: :cascade do |t|
    t.string   "name",                                     null: false
    t.integer  "github_id",                                null: false
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.boolean  "enabled",                  default: false, null: false
    t.integer  "users_count",              default: 0,     null: false
    t.integer  "owned_repositories_count", default: 0,     null: false
    t.string   "avatar_url"
    t.datetime "webhook_updated_at"
    t.date     "scored_up_to"
    t.date     "rewarded_up_to"
  end

  add_index "organisations", ["github_id"], name: "index_organisations_on_github_id", unique: true, using: :btree
  add_index "organisations", ["name"], name: "index_organisations_on_name", unique: true, using: :btree

  create_table "pull_requests", force: :cascade do |t|
    t.integer  "github_id",                     null: false
    t.integer  "github_number",                 null: false
    t.integer  "repository_id",                 null: false
    t.integer  "created_by_id",                 null: false
    t.integer  "merged_by_id"
    t.integer  "status",                        null: false
    t.datetime "merged_at"
    t.datetime "github_updated_at",             null: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.integer  "comments_count",    default: 0, null: false
    t.integer  "merge_time"
    t.string   "title"
  end

  add_index "pull_requests", ["created_at"], name: "index_pull_requests_on_created_at", using: :btree
  add_index "pull_requests", ["created_by_id"], name: "index_pull_requests_on_created_by_id", using: :btree
  add_index "pull_requests", ["github_id"], name: "index_pull_requests_on_github_id", unique: true, using: :btree
  add_index "pull_requests", ["merged_at"], name: "index_pull_requests_on_merged_at", using: :btree
  add_index "pull_requests", ["merged_by_id"], name: "index_pull_requests_on_merged_by_id", using: :btree
  add_index "pull_requests", ["repository_id"], name: "index_pull_requests_on_repository_id", using: :btree

  create_table "repositories", force: :cascade do |t|
    t.integer  "owner_id",                       null: false
    t.string   "owner_type",                     null: false
    t.string   "name",                           null: false
    t.integer  "github_id",                      null: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.boolean  "enabled",        default: false, null: false
    t.integer  "users_count",    default: 0,     null: false
    t.string   "description"
    t.boolean  "public",         default: false
    t.datetime "prs_updated_at"
  end

  add_index "repositories", ["github_id"], name: "index_repositories_on_github_id", unique: true, using: :btree
  add_index "repositories", ["name", "owner_id", "owner_type"], name: "index_repositories_on_name_and_owner_id_and_owner_type", using: :btree
  add_index "repositories", ["owner_id"], name: "index_repositories_on_owner_id", using: :btree
  add_index "repositories", ["owner_type", "owner_id"], name: "index_repositories_on_owner_type_and_owner_id", using: :btree

  create_table "rewards", force: :cascade do |t|
    t.integer  "organisation_id", null: false
    t.integer  "user_id",         null: false
    t.integer  "nature",          null: false
    t.date     "date",            null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "rewards", ["date", "organisation_id", "user_id"], name: "index_rewards_on_date_and_organisation_id_and_user_id", using: :btree

  create_table "team_users", force: :cascade do |t|
    t.integer  "user_id",                null: false
    t.integer  "team_id",                null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "role",       default: 1, null: false
  end

  add_index "team_users", ["team_id"], name: "index_team_users_on_team_id", using: :btree
  add_index "team_users", ["user_id", "team_id"], name: "index_team_users_on_user_id_and_team_id", unique: true, using: :btree
  add_index "team_users", ["user_id"], name: "index_team_users_on_user_id", using: :btree

  create_table "teams", force: :cascade do |t|
    t.integer  "github_id",                      null: false
    t.string   "name",                           null: false
    t.integer  "organisation_id",                null: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.boolean  "enabled",         default: true, null: false
    t.string   "slug",                           null: false
    t.string   "description"
  end

  add_index "teams", ["github_id"], name: "index_teams_on_github_id", using: :btree
  add_index "teams", ["name", "organisation_id"], name: "index_teams_on_name_and_organisation_id", using: :btree
  add_index "teams", ["organisation_id"], name: "index_teams_on_organisation_id", using: :btree

  create_table "user_repositories", force: :cascade do |t|
    t.integer  "user_id",       null: false
    t.integer  "repository_id", null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "user_repositories", ["repository_id"], name: "index_user_repositories_on_repository_id", using: :btree
  add_index "user_repositories", ["user_id", "repository_id"], name: "index_user_repositories_on_user_id_and_repository_id", unique: true, using: :btree
  add_index "user_repositories", ["user_id"], name: "index_user_repositories_on_user_id", using: :btree

  create_table "user_settings", force: :cascade do |t|
    t.integer  "user_id",                              null: false
    t.datetime "weekly_email_at"
    t.datetime "daily_email_at"
    t.datetime "snooze_until"
    t.boolean  "weekly_email_enabled", default: true,  null: false
    t.boolean  "daily_email_enabled",  default: true,  null: false
    t.boolean  "newsletter_enabled",   default: true,  null: false
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.string   "tz",                   default: "UTC", null: false
    t.text     "emails"
  end

  add_index "user_settings", ["user_id"], name: "index_user_settings_on_user_id", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "token"
    t.integer  "github_id",                                null: false
    t.string   "github_token"
    t.string   "login",                                    null: false
    t.string   "name"
    t.string   "email"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.integer  "throttle_limit"
    t.integer  "throttle_left"
    t.datetime "throttle_reset_at"
    t.integer  "owned_repositories_count", default: 0,     null: false
    t.integer  "repositories_count",       default: 0,     null: false
    t.boolean  "admin",                    default: false, null: false
  end

  add_index "users", ["github_id"], name: "index_users_on_github_id", unique: true, using: :btree
  add_index "users", ["login"], name: "index_users_on_login", unique: true, using: :btree
  add_index "users", ["throttle_left"], name: "index_users_on_throttle_left", where: "(github_token IS NOT NULL)", using: :btree
  add_index "users", ["token"], name: "index_users_on_token", using: :btree

  add_foreign_key "comments", "pull_requests"
  add_foreign_key "comments", "users"
  add_foreign_key "organisation_user_scores", "organisations"
  add_foreign_key "organisation_user_scores", "users"
  add_foreign_key "organisation_users", "organisations"
  add_foreign_key "organisation_users", "users"
  add_foreign_key "pull_requests", "repositories"
  add_foreign_key "pull_requests", "users", column: "created_by_id"
  add_foreign_key "pull_requests", "users", column: "merged_by_id"
  add_foreign_key "rewards", "organisations"
  add_foreign_key "rewards", "users"
  add_foreign_key "team_users", "teams"
  add_foreign_key "team_users", "users"
  add_foreign_key "teams", "organisations"
  add_foreign_key "user_repositories", "repositories"
  add_foreign_key "user_repositories", "users"
  add_foreign_key "user_settings", "users"
end
