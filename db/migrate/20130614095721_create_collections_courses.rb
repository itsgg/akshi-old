class CreateCollectionsCourses < ActiveRecord::Migration
  def change
    create_table :collections_courses, :id => false do |t|
      t.integer :course_id
      t.integer :collection_id
    end
  end
end
