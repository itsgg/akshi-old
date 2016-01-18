class AddSubjectToQuizzes < ActiveRecord::Migration
  def change
    add_column :quizzes, :subject_id, :integer
  end
end
