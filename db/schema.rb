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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140823183707) do

  create_table "announcements", :force => true do |t|
    t.text     "content",    :limit => 2147483647
    t.integer  "course_id"
    t.integer  "user_id"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.integer  "subject_id"
  end

  add_index "announcements", ["course_id"], :name => "index_announcements_on_course_id"
  add_index "announcements", ["user_id"], :name => "index_announcements_on_user_id"

  create_table "answers", :force => true do |t|
    t.text     "content",     :limit => 2147483647
    t.integer  "question_id"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

  add_index "answers", ["question_id"], :name => "index_answers_on_question_id"

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "position"
  end

  create_table "chats", :force => true do |t|
    t.text     "content",    :limit => 2147483647
    t.integer  "course_id"
    t.integer  "user_id"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  add_index "chats", ["course_id"], :name => "index_chats_on_course_id"
  add_index "chats", ["user_id"], :name => "index_chats_on_user_id"

  create_table "collections", :force => true do |t|
    t.string   "name"
    t.string   "ancestry"
    t.datetime "created_at",                                     :null => false
    t.datetime "updated_at",                                     :null => false
    t.integer  "position"
    t.text     "description"
    t.string   "cover_file_name"
    t.string   "cover_content_type"
    t.integer  "cover_file_size"
    t.datetime "cover_updated_at"
    t.integer  "discount"
    t.text     "offline_payment_instruction"
    t.boolean  "paid",                        :default => false
  end

  add_index "collections", ["ancestry"], :name => "index_collections_on_ancestry"

  create_table "collections_courses", :id => false, :force => true do |t|
    t.integer "course_id"
    t.integer "collection_id"
  end

  add_index "collections_courses", ["collection_id", "course_id"], :name => "index_collections_courses_on_collection_id_and_course_id"
  add_index "collections_courses", ["course_id", "collection_id"], :name => "index_collections_courses_on_course_id_and_collection_id"

  create_table "comments", :force => true do |t|
    t.integer  "post_id"
    t.text     "content"
    t.string   "email"
    t.string   "status",     :default => "review"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.integer  "user_id"
  end

  add_index "comments", ["post_id"], :name => "index_comments_on_post_id"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "courses", :force => true do |t|
    t.string   "name"
    t.text     "description",                 :limit => 2147483647
    t.integer  "category_id"
    t.datetime "created_at",                                                           :null => false
    t.datetime "updated_at",                                                           :null => false
    t.string   "cover_file_name"
    t.string   "cover_content_type"
    t.integer  "cover_file_size"
    t.datetime "cover_updated_at"
    t.float    "average_score",                                     :default => 0.0,   :null => false
    t.string   "status",                                            :default => "new"
    t.float    "amount",                                            :default => 0.0
    t.string   "currency",                                          :default => "INR"
    t.boolean  "paid",                                              :default => false
    t.text     "offline_payment_instruction"
    t.text     "features"
    t.boolean  "featured",                                          :default => false
  end

  add_index "courses", ["category_id"], :name => "index_courses_on_category_id"

  create_table "lessons", :force => true do |t|
    t.string   "name"
    t.integer  "course_id"
    t.datetime "created_at",                                                   :null => false
    t.datetime "updated_at",                                                   :null => false
    t.string   "upload_file_name"
    t.string   "upload_content_type"
    t.integer  "upload_file_size"
    t.datetime "upload_updated_at"
    t.integer  "position"
    t.text     "content",             :limit => 2147483647
    t.boolean  "published",                                 :default => false
    t.integer  "subject_id"
  end

  add_index "lessons", ["course_id"], :name => "index_lessons_on_course_id"

  create_table "posts", :force => true do |t|
    t.string   "title"
    t.text     "content",    :limit => 2147483647
    t.integer  "user_id"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  add_index "posts", ["user_id"], :name => "index_posts_on_user_id"

  create_table "questions", :force => true do |t|
    t.text     "content",           :limit => 2147483647
    t.integer  "quiz_id"
    t.integer  "correct_answer_id"
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
  end

  add_index "questions", ["correct_answer_id"], :name => "index_questions_on_correct_answer_id"
  add_index "questions", ["quiz_id"], :name => "index_questions_on_quiz_id"

  create_table "quiz_sessions", :force => true do |t|
    t.integer  "quiz_id"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "quiz_sessions", ["quiz_id"], :name => "index_quiz_sessions_on_quiz_id"
  add_index "quiz_sessions", ["user_id"], :name => "index_quiz_sessions_on_user_id"

  create_table "quizzes", :force => true do |t|
    t.string   "name"
    t.text     "instruction",           :limit => 2147483647
    t.integer  "course_id"
    t.datetime "created_at",                                                     :null => false
    t.datetime "updated_at",                                                     :null => false
    t.boolean  "published",                                   :default => false
    t.float    "time_limit_in_minutes",                       :default => 0.0
    t.integer  "position"
    t.boolean  "allow_review",                                :default => true
    t.integer  "subject_id"
  end

  add_index "quizzes", ["course_id"], :name => "index_quizzes_on_course_id"

  create_table "quizzes_subjects", :id => false, :force => true do |t|
    t.integer "subject_id"
    t.integer "quiz_id"
  end

  create_table "ratings", :force => true do |t|
    t.integer  "owner_id"
    t.integer  "ratable_id"
    t.string   "ratable_type"
    t.float    "score"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "ratings", ["owner_id"], :name => "index_ratings_on_owner_id"
  add_index "ratings", ["ratable_id", "ratable_type"], :name => "index_ratings_on_ratable_id_and_ratable_type"

  create_table "read_marks", :force => true do |t|
    t.integer  "readable_id"
    t.integer  "user_id",                     :null => false
    t.string   "readable_type", :limit => 20, :null => false
    t.datetime "timestamp"
  end

  add_index "read_marks", ["user_id", "readable_type", "readable_id"], :name => "index_read_marks_on_user_id_and_readable_type_and_readable_id"

  create_table "responses", :force => true do |t|
    t.integer  "user_id"
    t.integer  "question_id"
    t.integer  "answer_id"
    t.integer  "quiz_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "responses", ["answer_id"], :name => "index_responses_on_answer_id"
  add_index "responses", ["question_id"], :name => "index_responses_on_question_id"
  add_index "responses", ["quiz_id"], :name => "index_responses_on_quiz_id"
  add_index "responses", ["user_id"], :name => "index_responses_on_user_id"

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.integer  "user_id"
    t.integer  "course_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "roles", ["course_id"], :name => "index_roles_on_course_id"
  add_index "roles", ["user_id"], :name => "index_roles_on_user_id"

  create_table "schedules", :force => true do |t|
    t.string   "description"
    t.datetime "start_time"
    t.integer  "course_id"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.string   "mode",        :default => "LIVE"
    t.integer  "lesson_id"
  end

  add_index "schedules", ["course_id"], :name => "index_schedules_on_course_id"

  create_table "scores", :force => true do |t|
    t.integer  "user_id"
    t.integer  "quiz_id"
    t.integer  "total_questions", :default => 0
    t.integer  "correct_answers", :default => 0
    t.datetime "start_time"
    t.boolean  "finished",        :default => false
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
  end

  add_index "scores", ["quiz_id"], :name => "index_scores_on_quiz_id"
  add_index "scores", ["user_id"], :name => "index_scores_on_user_id"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "sites", :force => true do |t|
    t.boolean  "broadcasting", :default => false
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  create_table "subjects", :force => true do |t|
    t.string   "name"
    t.integer  "course_id"
    t.integer  "position"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "topics", :force => true do |t|
    t.text     "content",    :limit => 2147483647
    t.integer  "course_id"
    t.integer  "user_id"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.integer  "parent_id"
    t.string   "title"
    t.integer  "subject_id"
  end

  add_index "topics", ["course_id"], :name => "index_topics_on_course_id"
  add_index "topics", ["parent_id"], :name => "index_topics_on_parent_id"
  add_index "topics", ["user_id"], :name => "index_topics_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "username"
    t.string   "fullname"
    t.string   "email"
    t.text     "about",                :limit => 2147483647
    t.string   "password_digest"
    t.datetime "created_at",                                                    :null => false
    t.datetime "updated_at",                                                    :null => false
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.string   "reset_password_token"
    t.string   "authentication_token"
    t.boolean  "announcement_notify",                        :default => true
    t.boolean  "admin",                                      :default => false
    t.boolean  "discussion_notify",                          :default => true
    t.boolean  "blocked",                                    :default => false
    t.text     "session_id"
    t.boolean  "schedule_notify",                            :default => true
    t.string   "phone_number"
    t.string   "state_city"
    t.string   "institution"
    t.string   "date_of_birth"
  end

  create_table "vouchers", :force => true do |t|
    t.string   "code"
    t.string   "status",     :default => "new"
    t.integer  "course_id"
    t.integer  "user_id"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  add_index "vouchers", ["course_id"], :name => "index_vouchers_on_course_id"
  add_index "vouchers", ["user_id"], :name => "index_vouchers_on_user_id"

end
