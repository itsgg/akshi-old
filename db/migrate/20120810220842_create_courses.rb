class CreateCourses < ActiveRecord::Migration
  def change
    create_table :courses do |t|
      t.string :name
      t.text :description
      t.references :category

      t.timestamps
    end

    add_index :courses, :category_id
  end
end
