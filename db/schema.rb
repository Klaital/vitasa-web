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

ActiveRecord::Schema.define(version: 20190915221508) do

  create_table "calendars", force: :cascade do |t|
    t.date     "date"
    t.time     "open"
    t.time     "close"
    t.boolean  "is_closed"
    t.text     "notes"
    t.integer  "site_id"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.boolean  "backup_coordinator_today"
    t.integer  "efilers_needed"
    t.index ["site_id"], name: "index_calendars_on_site_id"
  end

  create_table "notification_registrations", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "token"
    t.string   "platform"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "endpoint"
    t.string   "subscription"
    t.index ["user_id"], name: "index_notification_registrations_on_user_id"
  end

  create_table "notification_requests", force: :cascade do |t|
    t.string   "audience"
    t.text     "message"
    t.datetime "sent"
    t.string   "message_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "organizations", force: :cascade do |t|
    t.string "slug", null: false
    t.string "name", null: false
  end

  create_table "preferred_sites", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "site_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "resource_translations", force: :cascade do |t|
    t.integer  "resource_id", null: false
    t.string   "locale",      null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.text     "text"
    t.index ["locale"], name: "index_resource_translations_on_locale"
    t.index ["resource_id"], name: "index_resource_translations_on_resource_id"
  end

  create_table "resources", force: :cascade do |t|
    t.string   "slug"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_resources_on_slug"
  end

  create_table "role_grants", force: :cascade do |t|
    t.integer  "role_id"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["role_id"], name: "index_role_grants_on_role_id"
    t.index ["user_id"], name: "index_role_grants_on_user_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "site_features", force: :cascade do |t|
    t.integer  "site_id"
    t.string   "feature"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["feature"], name: "index_site_features_on_feature"
    t.index ["site_id"], name: "index_site_features_on_site_id"
  end

  create_table "site_hits", force: :cascade do |t|
    t.string   "method"
    t.string   "path"
    t.string   "format"
    t.string   "controller"
    t.string   "action"
    t.integer  "status"
    t.float    "duration"
    t.float    "view"
    t.float    "db"
    t.datetime "timestamp"
    t.string   "cookie"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["format"], name: "index_site_hits_on_format"
    t.index ["method"], name: "index_site_hits_on_method"
    t.index ["path"], name: "index_site_hits_on_path"
    t.index ["status"], name: "index_site_hits_on_status"
    t.index ["timestamp"], name: "index_site_hits_on_timestamp"
  end

  create_table "sites", force: :cascade do |t|
    t.string   "name"
    t.string   "street"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "latitude"
    t.string   "longitude"
    t.integer  "sitecoordinator"
    t.string   "sitestatus"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.string   "google_place_id"
    t.string   "slug"
    t.time     "monday_open"
    t.time     "monday_close"
    t.time     "tuesday_open"
    t.time     "tuesday_close"
    t.time     "wednesday_open"
    t.time     "wednesday_close"
    t.time     "thursday_open"
    t.time     "thursday_close"
    t.time     "friday_open"
    t.time     "friday_close"
    t.time     "saturday_open"
    t.time     "saturday_close"
    t.time     "sunday_open"
    t.time     "sunday_close"
    t.integer  "backup_coordinator_id"
    t.integer  "monday_efilers"
    t.integer  "tuesday_efilers"
    t.integer  "wednesday_efilers"
    t.integer  "thursday_efilers"
    t.integer  "friday_efilers"
    t.integer  "saturday_efilers"
    t.integer  "sunday_efilers"
    t.date     "season_start"
    t.date     "season_end"
    t.boolean  "active",                default: true
    t.string   "contact_name"
    t.string   "contact_phone"
    t.text     "notes"
    t.string   "sns_topic"
    t.integer  "organization_id"
    t.index ["slug"], name: "index_sites_on_slug"
  end

  create_table "suggestions", force: :cascade do |t|
    t.string   "subject"
    t.text     "details"
    t.integer  "user_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "status"
    t.boolean  "from_public"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email"
    t.string   "password_digest"
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.string   "name"
    t.string   "phone"
    t.string   "certification"
    t.boolean  "subscribe_mobile",                            null: false
    t.string   "mobile_subscription_arn"
    t.boolean  "hsa_certification"
    t.boolean  "military_certification"
    t.boolean  "international_certification", default: false, null: false
    t.integer  "organization_id"
  end

  create_table "users_sites", id: false, force: :cascade do |t|
    t.integer "site_id"
    t.integer "user_id"
    t.index ["site_id"], name: "index_users_sites_on_site_id"
    t.index ["user_id"], name: "index_users_sites_on_user_id"
  end

  create_table "work_logs", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "site_id"
    t.boolean  "approved",   default: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.string   "date"
    t.float    "hours"
  end

end
