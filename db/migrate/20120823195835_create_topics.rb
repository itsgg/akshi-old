class CreateTopics < ActiveRecord::Migration
  def change
    create_table :topics do |t|
      t.text :content
      t.references :course
      t.references :user
      t.timestamps
    end

    add_index :topics, :course_id
    add_index :topics, :user_id
  end
end
