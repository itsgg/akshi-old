class AddFeaturedCourseToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :featured_course, :boolean, :default => false
  end
end
