class CreateScores < ActiveRecord::Migration
  def change
    create_table :scores do |t|
      t.references :user
      t.references :quiz
      t.integer :total_questions, :default => 0
      t.integer :correct_answers, :default => 0
      t.datetime :start_time
      t.boolean :finished, :default => false
      t.timestamps
    end
  end
end
