class AddFeaturesToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :features, :text
  end
end
