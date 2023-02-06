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

ActiveRecord::Schema[7.0].define(version: 2023_02_06_205947) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "courses", force: :cascade do |t|
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.text "description"
    t.bigint "host_id", null: false
    t.index ["host_id"], name: "index_courses_on_host_id"
  end

  create_table "instructed_courses_instructors", id: false, force: :cascade do |t|
    t.bigint "instructed_course_id", null: false
    t.bigint "instructor_id", null: false
    t.index ["instructed_course_id", "instructor_id"], name: "unique_index", unique: true
    t.index ["instructed_course_id"], name: "index_instructed_courses_instructors_on_instructed_course_id"
    t.index ["instructor_id"], name: "index_instructed_courses_instructors_on_instructor_id"
  end

  create_table "instruction_invitations", force: :cascade do |t|
    t.integer "response", default: 0
    t.bigint "course_id", null: false
    t.bigint "sender_id", null: false
    t.bigint "recipient_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_instruction_invitations_on_course_id"
    t.index ["recipient_id"], name: "index_instruction_invitations_on_recipient_id"
    t.index ["sender_id"], name: "index_instruction_invitations_on_sender_id"
  end

  create_table "lesson_sections", force: :cascade do |t|
    t.string "title"
    t.text "body"
    t.integer "order"
    t.bigint "lesson_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lesson_id"], name: "index_lesson_sections_on_lesson_id"
  end

  create_table "lessons", force: :cascade do |t|
    t.bigint "course_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.integer "order"
    t.index ["course_id"], name: "index_lessons_on_course_id"
  end

  create_table "profiles", force: :cascade do |t|
    t.string "first_name"
    t.string "middle_name"
    t.string "last_name"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_profiles_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "username"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "courses", "users", column: "host_id"
  add_foreign_key "instruction_invitations", "courses"
  add_foreign_key "instruction_invitations", "users", column: "recipient_id"
  add_foreign_key "instruction_invitations", "users", column: "sender_id"
  add_foreign_key "lesson_sections", "lessons"
  add_foreign_key "lessons", "courses"
  add_foreign_key "profiles", "users"
end
