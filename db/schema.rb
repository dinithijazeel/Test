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

ActiveRecord::Schema.define(version: 20170210170115) do

  create_table "boms", force: :cascade do |t|
    t.string   "type",           limit: 255
    t.string   "number",         limit: 255
    t.date     "invoice_date"
    t.integer  "invoice_status", limit: 4,   default: 0
    t.integer  "rating_status",  limit: 4,   default: 0
    t.integer  "terms",          limit: 4
    t.float    "invoice_total",  limit: 24,  default: 0.0
    t.float    "total_payments", limit: 24,  default: 0.0
    t.float    "total_due",      limit: 24,  default: 0.0
    t.integer  "payment_status", limit: 4,   default: 0
    t.string   "memo",           limit: 255,               null: false
    t.string   "pdf",            limit: 255
    t.integer  "contact_id",     limit: 4
    t.string   "portal_id",      limit: 255
    t.string   "cdr_url",        limit: 255
    t.string   "did_url",        limit: 255
    t.string   "payment_token",  limit: 255
    t.integer  "creator_id",     limit: 4
    t.integer  "last_editor_id", limit: 4
    t.datetime "rated_at"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.datetime "deleted_at"
  end

  add_index "boms", ["contact_id"], name: "index_boms_on_contact_id", using: :btree
  add_index "boms", ["creator_id"], name: "index_boms_on_creator_id", using: :btree
  add_index "boms", ["invoice_date"], name: "index_boms_on_invoice_date", using: :btree
  add_index "boms", ["invoice_status"], name: "index_boms_on_invoice_status", using: :btree
  add_index "boms", ["last_editor_id"], name: "index_boms_on_last_editor_id", using: :btree
  add_index "boms", ["number"], name: "index_boms_on_number", using: :btree
  add_index "boms", ["payment_status"], name: "index_boms_on_payment_status", using: :btree
  add_index "boms", ["terms"], name: "index_boms_on_terms", using: :btree

  create_table "comments", force: :cascade do |t|
    t.integer  "commentable_id",   limit: 4
    t.string   "commentable_type", limit: 255
    t.string   "title",            limit: 255
    t.text     "body",             limit: 65535
    t.string   "subject",          limit: 255
    t.integer  "user_id",          limit: 4,     null: false
    t.integer  "parent_id",        limit: 4
    t.integer  "lft",              limit: 4
    t.integer  "rgt",              limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["commentable_id", "commentable_type"], name: "index_comments_on_commentable_id_and_commentable_type", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "contacts", force: :cascade do |t|
    t.string   "type",                    limit: 255
    t.integer  "customer_status",         limit: 4,   default: 0
    t.string   "contact_first",           limit: 255,                null: false
    t.string   "contact_last",            limit: 255,                null: false
    t.string   "company_name",            limit: 255,                null: false
    t.string   "admin_email",             limit: 255
    t.string   "phone",                   limit: 255,                null: false
    t.string   "billing_email",           limit: 255,                null: false
    t.integer  "default_terms",           limit: 4,   default: 0
    t.string   "billing_street_1",        limit: 255,                null: false
    t.string   "billing_street_2",        limit: 255,                null: false
    t.string   "billing_city",            limit: 255,                null: false
    t.string   "billing_state",           limit: 255,                null: false
    t.string   "billing_zip",             limit: 255,                null: false
    t.string   "billing_country",         limit: 255,                null: false
    t.boolean  "use_billing_for_service",             default: true
    t.string   "service_street_1",        limit: 255,                null: false
    t.string   "service_street_2",        limit: 255,                null: false
    t.string   "service_city",            limit: 255,                null: false
    t.string   "service_state",           limit: 255,                null: false
    t.string   "service_zip",             limit: 255,                null: false
    t.string   "service_country",         limit: 255,                null: false
    t.string   "affiliate_id",            limit: 255,                null: false
    t.string   "discount_code",           limit: 255,                null: false
    t.string   "portal_id",               limit: 255
    t.integer  "creator_id",              limit: 4
    t.integer  "last_editor_id",          limit: 4
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
  end

  add_index "contacts", ["admin_email"], name: "index_contacts_on_admin_email", using: :btree
  add_index "contacts", ["billing_email"], name: "index_contacts_on_billing_email", using: :btree
  add_index "contacts", ["company_name"], name: "index_contacts_on_company_name", using: :btree
  add_index "contacts", ["contact_first"], name: "index_contacts_on_contact_first", using: :btree
  add_index "contacts", ["contact_last"], name: "index_contacts_on_contact_last", using: :btree
  add_index "contacts", ["creator_id"], name: "index_contacts_on_creator_id", using: :btree
  add_index "contacts", ["customer_status"], name: "index_contacts_on_customer_status", using: :btree
  add_index "contacts", ["default_terms"], name: "index_contacts_on_default_terms", using: :btree
  add_index "contacts", ["last_editor_id"], name: "index_contacts_on_last_editor_id", using: :btree
  add_index "contacts", ["portal_id"], name: "index_contacts_on_portal_id", using: :btree
  add_index "contacts", ["type"], name: "index_contacts_on_type", using: :btree

  create_table "credits", force: :cascade do |t|
    t.float    "amount",     limit: 24
    t.integer  "payment_id", limit: 4
    t.integer  "invoice_id", limit: 4
    t.integer  "creator_id", limit: 4
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "credits", ["creator_id"], name: "index_credits_on_creator_id", using: :btree
  add_index "credits", ["invoice_id"], name: "index_credits_on_invoice_id", using: :btree
  add_index "credits", ["payment_id"], name: "index_credits_on_payment_id", using: :btree

  create_table "line_items", force: :cascade do |t|
    t.string   "description", limit: 255
    t.float    "quantity",    limit: 24,  default: 0.0
    t.float    "unit_price",  limit: 24,  default: 0.0
    t.float    "total",       limit: 24,  default: 0.0
    t.integer  "bom_id",      limit: 4
    t.integer  "product_id",  limit: 4
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.datetime "deleted_at"
  end

  add_index "line_items", ["bom_id"], name: "index_line_items_on_bom_id", using: :btree
  add_index "line_items", ["product_id"], name: "index_line_items_on_product_id", using: :btree

  create_table "onboarding", force: :cascade do |t|
    t.string   "service_type",         limit: 255
    t.integer  "service_quantity",     limit: 4
    t.float    "service_unit_price",   limit: 24
    t.integer  "addl_dids_quantity",   limit: 4
    t.float    "addl_dids_unit_price", limit: 24
    t.integer  "fax_quantity",         limit: 4
    t.float    "fax_unit_price",       limit: 24
    t.string   "installation",         limit: 255
    t.text     "installation_notes",   limit: 65535
    t.boolean  "local_port"
    t.boolean  "tollfree_port"
    t.float    "discount",             limit: 24
    t.integer  "proposal_id",          limit: 4
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  add_index "onboarding", ["local_port"], name: "index_onboarding_on_local_port", using: :btree
  add_index "onboarding", ["proposal_id"], name: "index_onboarding_on_proposal_id", using: :btree
  add_index "onboarding", ["tollfree_port"], name: "index_onboarding_on_tollfree_port", using: :btree

  create_table "opportunities", force: :cascade do |t|
    t.string   "need",           limit: 255, null: false
    t.string   "budget",         limit: 255, null: false
    t.string   "timing",         limit: 255, null: false
    t.string   "decision_maker", limit: 255, null: false
    t.string   "competition",    limit: 255, null: false
    t.integer  "contact_id",     limit: 4
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "opportunities", ["contact_id"], name: "index_opportunities_on_contact_id", using: :btree

  create_table "payments", force: :cascade do |t|
    t.integer  "payment_status", limit: 4,     default: 0
    t.string   "payment_type",   limit: 255
    t.date     "payment_date"
    t.float    "amount",         limit: 24,                  null: false
    t.float    "balance",        limit: 24,                  null: false
    t.float    "fee",            limit: 24,    default: 0.0
    t.text     "memo",           limit: 65535,               null: false
    t.integer  "customer_id",    limit: 4
    t.integer  "payable_id",     limit: 4
    t.string   "payable_type",   limit: 255
    t.string   "client_ip",      limit: 255,                 null: false
    t.integer  "creator_id",     limit: 4
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  add_index "payments", ["creator_id"], name: "index_payments_on_creator_id", using: :btree
  add_index "payments", ["customer_id"], name: "index_payments_on_customer_id", using: :btree
  add_index "payments", ["payment_date"], name: "index_payments_on_payment_date", using: :btree
  add_index "payments", ["payment_status"], name: "index_payments_on_payment_status", using: :btree
  add_index "payments", ["payment_type"], name: "index_payments_on_payment_type", using: :btree

  create_table "products", force: :cascade do |t|
    t.string   "sku",              limit: 255,                  null: false
    t.string   "vendor_sku",       limit: 255
    t.string   "name",             limit: 255,                  null: false
    t.text     "description",      limit: 65535,                null: false
    t.float    "price",            limit: 24
    t.float    "weight",           limit: 24
    t.string   "units",            limit: 255,                  null: false
    t.float    "default_quantity", limit: 24,    default: 1.0
    t.integer  "product_status",   limit: 4,     default: 0
    t.integer  "product_type",     limit: 4,     default: 0
    t.integer  "billing",          limit: 4,     default: 0
    t.boolean  "fixed_price",                    default: true
    t.string   "datasheet",        limit: 255
    t.integer  "vendor_id",        limit: 4
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
  end

  add_index "products", ["billing"], name: "index_products_on_billing", using: :btree
  add_index "products", ["name"], name: "index_products_on_name", using: :btree
  add_index "products", ["product_status"], name: "index_products_on_product_status", using: :btree
  add_index "products", ["product_type"], name: "index_products_on_product_type", using: :btree
  add_index "products", ["sku"], name: "index_products_on_sku", using: :btree
  add_index "products", ["vendor_id"], name: "index_products_on_vendor_id", using: :btree

  create_table "proposals", force: :cascade do |t|
    t.integer  "proposal_status",      limit: 4,   default: 0
    t.date     "proposal_date"
    t.string   "number",               limit: 255
    t.string   "memo",                 limit: 255,               null: false
    t.float    "total",                limit: 24,  default: 0.0
    t.string   "pdf",                  limit: 255
    t.integer  "contact_id",           limit: 4
    t.integer  "services_proposal_id", limit: 4
    t.integer  "products_proposal_id", limit: 4
    t.integer  "creator_id",           limit: 4
    t.integer  "last_editor_id",       limit: 4
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
  end

  add_index "proposals", ["contact_id"], name: "index_proposals_on_contact_id", using: :btree
  add_index "proposals", ["creator_id"], name: "index_proposals_on_creator_id", using: :btree
  add_index "proposals", ["last_editor_id"], name: "index_proposals_on_last_editor_id", using: :btree
  add_index "proposals", ["number"], name: "index_proposals_on_number", using: :btree
  add_index "proposals", ["products_proposal_id"], name: "index_proposals_on_products_proposal_id", using: :btree
  add_index "proposals", ["proposal_date"], name: "index_proposals_on_proposal_date", using: :btree
  add_index "proposals", ["proposal_status"], name: "index_proposals_on_proposal_status", using: :btree
  add_index "proposals", ["services_proposal_id"], name: "index_proposals_on_services_proposal_id", using: :btree

  create_table "stripe_transactions", force: :cascade do |t|
    t.string  "token",               limit: 255, null: false
    t.integer "stripe_created",      limit: 4
    t.string  "client_ip",           limit: 255
    t.string  "card_id",             limit: 255, null: false
    t.string  "card_type",           limit: 255, null: false
    t.string  "brand",               limit: 255, null: false
    t.string  "name",                limit: 255, null: false
    t.integer "exp_month",           limit: 4
    t.integer "exp_year",            limit: 4
    t.integer "last4",               limit: 4
    t.string  "country",             limit: 255, null: false
    t.string  "funding",             limit: 255, null: false
    t.string  "address_line1",       limit: 255, null: false
    t.string  "address_line2",       limit: 255, null: false
    t.string  "address_state",       limit: 255, null: false
    t.string  "address_city",        limit: 255, null: false
    t.string  "address_zip",         limit: 255, null: false
    t.string  "address_country",     limit: 255, null: false
    t.string  "address_line1_check", limit: 255, null: false
    t.string  "address_zip_check",   limit: 255, null: false
    t.string  "cvc_check",           limit: 255, null: false
    t.integer "payment_id",          limit: 4
  end

  add_index "stripe_transactions", ["payment_id"], name: "index_stripe_transactions_on_payment_id", using: :btree
  add_index "stripe_transactions", ["token"], name: "index_stripe_transactions_on_token", using: :btree

  create_table "support_tickets", force: :cascade do |t|
    t.string   "reference",        limit: 255
    t.string   "ticket_status",    limit: 255
    t.integer  "supportable_id",   limit: 4
    t.string   "supportable_type", limit: 255
    t.integer  "system",           limit: 4,   default: 0
    t.integer  "foreign_id",       limit: 4
    t.integer  "onboarding_id",    limit: 4
    t.integer  "contact_id",       limit: 4
    t.datetime "synced_at"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
  end

  add_index "support_tickets", ["contact_id"], name: "index_support_tickets_on_contact_id", using: :btree
  add_index "support_tickets", ["foreign_id"], name: "index_support_tickets_on_foreign_id", using: :btree
  add_index "support_tickets", ["onboarding_id"], name: "index_support_tickets_on_onboarding_id", using: :btree
  add_index "support_tickets", ["supportable_id"], name: "index_support_tickets_on_supportable_id", using: :btree
  add_index "support_tickets", ["supportable_type"], name: "index_support_tickets_on_supportable_type", using: :btree
  add_index "support_tickets", ["system"], name: "index_support_tickets_on_system", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255,   default: "", null: false
    t.string   "encrypted_password",     limit: 255,   default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,     default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.integer  "role",                   limit: 4
    t.string   "first_name",             limit: 255,   default: "", null: false
    t.string   "last_name",              limit: 255,   default: "", null: false
    t.string   "title",                  limit: 255,   default: "", null: false
    t.string   "phone",                  limit: 255,   default: "", null: false
    t.string   "nickname",               limit: 255,   default: ""
    t.text     "about",                  limit: 65535
    t.integer  "contact_id",             limit: 4
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.datetime "deleted_at"
  end

  add_index "users", ["deleted_at"], name: "index_users_on_deleted_at", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["first_name"], name: "index_users_on_first_name", using: :btree
  add_index "users", ["last_name"], name: "index_users_on_last_name", using: :btree
  add_index "users", ["nickname"], name: "index_users_on_nickname", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["role"], name: "index_users_on_role", using: :btree

  create_table "vendors", force: :cascade do |t|
    t.string   "name",       limit: 255,                null: false
    t.boolean  "active",                 default: true
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  add_index "vendors", ["name"], name: "index_vendors_on_name", using: :btree

  add_foreign_key "boms", "contacts"
  add_foreign_key "boms", "users", column: "creator_id"
  add_foreign_key "boms", "users", column: "last_editor_id"
  add_foreign_key "contacts", "users", column: "creator_id"
  add_foreign_key "contacts", "users", column: "last_editor_id"
  add_foreign_key "credits", "boms", column: "invoice_id"
  add_foreign_key "credits", "payments"
  add_foreign_key "credits", "users", column: "creator_id"
  add_foreign_key "line_items", "boms"
  add_foreign_key "line_items", "products"
  add_foreign_key "onboarding", "proposals"
  add_foreign_key "opportunities", "contacts"
  add_foreign_key "payments", "contacts", column: "customer_id"
  add_foreign_key "payments", "users", column: "creator_id"
  add_foreign_key "products", "vendors"
  add_foreign_key "proposals", "boms", column: "products_proposal_id"
  add_foreign_key "proposals", "boms", column: "services_proposal_id"
  add_foreign_key "proposals", "contacts"
  add_foreign_key "proposals", "users", column: "creator_id"
  add_foreign_key "proposals", "users", column: "last_editor_id"
  add_foreign_key "stripe_transactions", "payments"
end
