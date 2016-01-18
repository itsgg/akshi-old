class CreateQuizzesAndSubjects < ActiveRecord::Migration
  def change
    create_table :quizzes_subjects, id: false do |t|
      t.belongs_to :subject
      t.belongs_to :quiz
    end
  end
end
