class CreateLessons < ActiveRecord::Migration
  def change
    create_table :lessons do |t|
      t.string :name
      t.references :course

      t.timestamps
    end
    add_index :lessons, :course_id
  end
end
