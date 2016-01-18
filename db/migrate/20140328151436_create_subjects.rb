class CreateSubjects < ActiveRecord::Migration
  def change
    create_table :subjects do |t|
      t.string :name
      t.integer :course_id
      t.integer :position
      t.timestamps
    end
  end
end
