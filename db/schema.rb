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

ActiveRecord::Schema[7.0].define(version: 2023_02_24_203103) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "assignment_submissions", force: :cascade do |t|
    t.integer "completion_status", default: 0
    t.bigint "assignment_id"
    t.bigint "student_id", null: false
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "completed_at"
    t.index ["assignment_id", "student_id"], name: "index_assignment_submissions_on_assignment_id_and_student_id", unique: true
    t.index ["assignment_id"], name: "index_assignment_submissions_on_assignment_id"
    t.index ["student_id"], name: "index_assignment_submissions_on_student_id"
  end

  create_table "assignments", force: :cascade do |t|
    t.string "title"
    t.text "body"
    t.bigint "lesson_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "order"
    t.index ["lesson_id"], name: "index_assignments_on_lesson_id"
  end

  create_table "comments", force: :cascade do |t|
    t.text "body"
    t.string "commentable_type", null: false
    t.bigint "commentable_id", null: false
    t.bigint "creator_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["commentable_type", "commentable_id"], name: "index_comments_on_reactable"
    t.index ["creator_id"], name: "index_comments_on_creator_id"
  end

  create_table "courses", force: :cascade do |t|
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.text "description"
    t.bigint "host_id", null: false
    t.index ["host_id"], name: "index_courses_on_host_id"
  end

  create_table "enrollments", force: :cascade do |t|
    t.bigint "course_id", null: false
    t.bigint "student_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id", "student_id"], name: "index_enrollments_on_course_id_and_student_id", unique: true
    t.index ["course_id"], name: "index_enrollments_on_course_id"
    t.index ["student_id"], name: "index_enrollments_on_student_id"
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

  create_table "messages", force: :cascade do |t|
    t.bigint "sender_id", null: false
    t.bigint "recipient_id", null: false
    t.integer "read_status", default: 0
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "parent_id"
    t.string "subject"
    t.string "messageable_type"
    t.bigint "messageable_id"
    t.index ["messageable_type", "messageable_id"], name: "index_messages_on_messageable"
    t.index ["parent_id"], name: "index_messages_on_parent_id"
    t.index ["recipient_id"], name: "index_messages_on_recipient_id"
    t.index ["sender_id"], name: "index_messages_on_sender_id"
  end

  create_table "posts", force: :cascade do |t|
    t.string "postable_type", null: false
    t.bigint "postable_id", null: false
    t.bigint "creator_id", null: false
    t.string "title"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_posts_on_creator_id"
    t.index ["postable_type", "postable_id"], name: "index_posts_on_postable"
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

  add_foreign_key "assignment_submissions", "assignments"
  add_foreign_key "assignment_submissions", "users", column: "student_id"
  add_foreign_key "assignments", "lessons"
  add_foreign_key "comments", "users", column: "creator_id"
  add_foreign_key "courses", "users", column: "host_id"
  add_foreign_key "enrollments", "courses"
  add_foreign_key "enrollments", "users", column: "student_id"
  add_foreign_key "instruction_invitations", "courses"
  add_foreign_key "instruction_invitations", "users", column: "recipient_id"
  add_foreign_key "instruction_invitations", "users", column: "sender_id"
  add_foreign_key "lesson_sections", "lessons"
  add_foreign_key "lessons", "courses"
  add_foreign_key "messages", "messages", column: "parent_id"
  add_foreign_key "messages", "users", column: "recipient_id"
  add_foreign_key "messages", "users", column: "sender_id"
  add_foreign_key "posts", "users", column: "creator_id"
  add_foreign_key "profiles", "users"
end
