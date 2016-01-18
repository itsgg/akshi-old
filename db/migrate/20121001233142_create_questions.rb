class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.text :content
      t.references :quiz
      t.references :correct_answer
      t.timestamps
    end
  end
end
