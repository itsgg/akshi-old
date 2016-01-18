class AddAllowReviewToQuizzes < ActiveRecord::Migration
  def change
    add_column :quizzes, :allow_review, :boolean, :default => true
  end
end
