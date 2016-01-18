class CreateResponses < ActiveRecord::Migration
  def change
    create_table :responses do |t|
      t.references :user
      t.references :question
      t.references :answer
      t.references :quiz
      t.timestamps
    end
  end
end
