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

ActiveRecord::Schema.define(version: 20160430145237) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "organisation_users", force: :cascade do |t|
    t.integer  "organisation_id"
    t.integer  "user_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "organisation_users", ["organisation_id"], name: "index_organisation_users_on_organisation_id", using: :btree
  add_index "organisation_users", ["user_id"], name: "index_organisation_users_on_user_id", using: :btree

  create_table "organisations", force: :cascade do |t|
    t.string   "name",       null: false
    t.integer  "github_id",  null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "organisations", ["github_id"], name: "index_organisations_on_github_id", unique: true, using: :btree
  add_index "organisations", ["name"], name: "index_organisations_on_name", unique: true, using: :btree

  create_table "repositories", force: :cascade do |t|
    t.integer  "owner_id",   null: false
    t.string   "owner_type", null: false
    t.string   "name",       null: false
    t.integer  "github_id",  null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "repositories", ["github_id"], name: "index_repositories_on_github_id", unique: true, using: :btree
  add_index "repositories", ["owner_id"], name: "index_repositories_on_owner_id", using: :btree
  add_index "repositories", ["owner_type", "owner_id"], name: "index_repositories_on_owner_type_and_owner_id", using: :btree

  create_table "user_repositories", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "repository_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "user_repositories", ["repository_id"], name: "index_user_repositories_on_repository_id", using: :btree
  add_index "user_repositories", ["user_id"], name: "index_user_repositories_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "token"
    t.integer  "github_id",    null: false
    t.string   "github_token"
    t.string   "login",        null: false
    t.string   "avatar_url",   null: false
    t.string   "name"
    t.string   "email"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "users", ["github_id"], name: "index_users_on_github_id", using: :btree

  add_foreign_key "organisation_users", "organisations"
  add_foreign_key "organisation_users", "users"
  add_foreign_key "user_repositories", "repositories"
  add_foreign_key "user_repositories", "users"
end
