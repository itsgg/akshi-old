class CreateQuizSessions < ActiveRecord::Migration
  def change
    create_table :quiz_sessions do |t|
      t.references :quiz
      t.references :user
      t.timestamps
    end
  end
end
