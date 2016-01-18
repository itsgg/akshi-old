class RemovePublishedFromCourse < ActiveRecord::Migration
  def up
  	remove_column :courses, :published
  end

  def down
  	add_column :courses, :published, :boolean
  end
end
