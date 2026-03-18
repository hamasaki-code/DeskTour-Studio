# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2026_03_12_130000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "items", force: :cascade do |t|
    t.bigint "post_id", null: false
    t.string "name", null: false
    t.string "affiliate_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_items_on_name"
    t.index ["post_id"], name: "index_items_on_post_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "post_id", null: false
    t.integer "kind", default: 0, null: false
    t.string "message", null: false
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_notifications_on_created_at"
    t.index ["post_id"], name: "index_notifications_on_post_id"
    t.index ["read_at"], name: "index_notifications_on_read_at"
  end

  create_table "posts", force: :cascade do |t|
    t.string "title", null: false
    t.text "description", null: false
    t.string "category"
    t.string "theme"
    t.string "tag_list"
    t.integer "likes_count", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.string "owner_token_digest", null: false
    t.index ["created_at"], name: "index_posts_on_created_at"
    t.index ["owner_token_digest"], name: "index_posts_on_owner_token_digest"
    t.index ["status"], name: "index_posts_on_status"
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "reports", force: :cascade do |t|
    t.bigint "post_id", null: false
    t.bigint "reporter_user_id"
    t.string "reporter_token", null: false
    t.integer "reason", default: 0, null: false
    t.text "details"
    t.integer "status", default: 0, null: false
    t.datetime "reviewed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_reports_on_created_at"
    t.index ["post_id", "reporter_token"], name: "index_reports_on_post_id_and_reporter_token", unique: true
    t.index ["post_id", "reporter_user_id"], name: "index_reports_on_post_id_and_reporter_user_id", unique: true, where: "(reporter_user_id IS NOT NULL)"
    t.index ["post_id"], name: "index_reports_on_post_id"
    t.index ["reporter_token", "created_at"], name: "index_reports_on_reporter_token_and_created_at"
    t.index ["reporter_user_id"], name: "index_reports_on_reporter_user_id"
    t.index ["status"], name: "index_reports_on_status"
  end

  create_table "support_requests", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "username"
    t.string "subject", null: false
    t.text "message", null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_support_requests_on_created_at"
    t.index ["status"], name: "index_support_requests_on_status"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.text "bio"
    t.string "owner_token_digest", null: false
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "username"
    t.string "password_digest"
    t.index ["created_at"], name: "index_users_on_created_at"
    t.index ["email"], name: "index_users_on_email"
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "items", "posts"
  add_foreign_key "notifications", "posts"
  add_foreign_key "posts", "users"
  add_foreign_key "reports", "posts"
  add_foreign_key "reports", "users", column: "reporter_user_id"
end
