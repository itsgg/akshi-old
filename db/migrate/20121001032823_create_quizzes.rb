class CreateQuizzes < ActiveRecord::Migration
  def change
    create_table :quizzes do |t|
      t.string :name
      t.text :instruction
      t.integer :time_limit_in_mins
      t.references :course
      t.timestamps
    end
  end
end
