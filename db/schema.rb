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

ActiveRecord::Schema[8.0].define(version: 2026_01_08_162615) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "audit_logs", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.bigint "user_id", null: false
    t.string "action"
    t.string "resource_type"
    t.bigint "resource_id"
    t.jsonb "metadata"
    t.inet "ip_address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_audit_logs_on_organization_id"
    t.index ["user_id"], name: "index_audit_logs_on_user_id"
  end

  create_table "compliance_categories", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.string "name", null: false
    t.string "color", default: "#1E293B"
    t.text "description"
    t.integer "default_reminder_days", default: [90, 60, 30, 7], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_compliance_categories_on_organization_id"
  end

  create_table "documents", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.bigint "compliance_category_id"
    t.bigint "uploaded_by_id", null: false
    t.bigint "assigned_to_id"
    t.string "name", null: false
    t.text "description"
    t.date "issue_date"
    t.date "expiration_date"
    t.string "status", default: "active"
    t.string "document_type"
    t.string "issuing_authority"
    t.string "reference_number"
    t.integer "reminder_days", default: [90, 60, 30, 7], array: true
    t.boolean "auto_remind", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assigned_to_id"], name: "index_documents_on_assigned_to_id"
    t.index ["compliance_category_id"], name: "index_documents_on_compliance_category_id"
    t.index ["expiration_date"], name: "index_documents_on_expiration_date"
    t.index ["organization_id", "status"], name: "index_documents_on_organization_id_and_status"
    t.index ["organization_id"], name: "index_documents_on_organization_id"
    t.index ["uploaded_by_id"], name: "index_documents_on_uploaded_by_id"
  end

  create_table "notification_settings", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.boolean "email_enabled", default: true
    t.string "email_from_name"
    t.boolean "sms_enabled", default: false
    t.string "twilio_phone_number"
    t.boolean "slack_enabled", default: false
    t.string "slack_webhook_url"
    t.string "slack_channel"
    t.integer "reminder_intervals", default: [90, 60, 30, 7], array: true
    t.boolean "escalation_enabled", default: true
    t.integer "escalation_after_days", default: 3
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_notification_settings_on_organization_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name"
    t.string "slug"
    t.string "industry"
    t.string "phone"
    t.string "address"
    t.string "city"
    t.string "state"
    t.string "zip_code"
    t.integer "compliance_health_score"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_organizations_on_slug"
  end

  create_table "plans", force: :cascade do |t|
    t.string "name"
    t.string "stripe_price_id"
    t.integer "price_cents"
    t.string "interval"
    t.integer "max_users"
    t.integer "max_documents"
    t.boolean "sms_enabled"
    t.boolean "slack_enabled"
    t.jsonb "features"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "reminders", force: :cascade do |t|
    t.bigint "document_id", null: false
    t.bigint "user_id", null: false
    t.datetime "scheduled_at"
    t.datetime "sent_at"
    t.string "channel"
    t.string "status"
    t.integer "days_before_expiry"
    t.integer "escalation_level"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["document_id"], name: "index_reminders_on_document_id"
    t.index ["user_id"], name: "index_reminders_on_user_id"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.bigint "plan_id", null: false
    t.string "stripe_subscription_id"
    t.string "stripe_customer_id"
    t.string "status"
    t.datetime "trial_ends_at"
    t.datetime "current_period_end"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_subscriptions_on_organization_id"
    t.index ["plan_id"], name: "index_subscriptions_on_plan_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "first_name"
    t.string "last_name"
    t.string "phone"
    t.string "role"
    t.string "title"
    t.string "license_number"
    t.date "license_expiration"
    t.bigint "organization_id"
    t.boolean "email_notifications"
    t.boolean "sms_notifications"
    t.string "invitation_token"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["organization_id"], name: "index_users_on_organization_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "audit_logs", "organizations"
  add_foreign_key "audit_logs", "users"
  add_foreign_key "compliance_categories", "organizations"
  add_foreign_key "documents", "compliance_categories"
  add_foreign_key "documents", "organizations"
  add_foreign_key "documents", "users", column: "assigned_to_id"
  add_foreign_key "documents", "users", column: "uploaded_by_id"
  add_foreign_key "notification_settings", "organizations"
  add_foreign_key "reminders", "documents"
  add_foreign_key "reminders", "users"
  add_foreign_key "subscriptions", "organizations"
  add_foreign_key "subscriptions", "plans"
end
