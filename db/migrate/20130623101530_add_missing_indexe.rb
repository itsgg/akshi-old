class AddMissingIndexe < ActiveRecord::Migration
  def change
    add_index :quiz_sessions, :quiz_id
    add_index :quiz_sessions, :user_id
    add_index :ratings, [:ratable_id, :ratable_type]
    add_index :ratings, :owner_id
    add_index :announcements, :user_id
    add_index :announcements, :course_id
    add_index :responses, :answer_id
    add_index :responses, :user_id
    add_index :responses, :quiz_id
    add_index :responses, :question_id
    add_index :schedules, :course_id
    add_index :scores, :user_id
    add_index :scores, :quiz_id
    add_index :collections_courses, [:collection_id, :course_id]
    add_index :collections_courses, [:course_id, :collection_id]
    add_index :vouchers, :course_id
    add_index :vouchers, :user_id
    add_index :comments, :post_id
    add_index :comments, :user_id
    add_index :answers, :question_id
    add_index :posts, :user_id
    add_index :questions, :quiz_id
    add_index :questions, :correct_answer_id
    add_index :quizzes, :course_id
  end
end
