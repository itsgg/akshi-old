class RenameFeaturedCourseToFeatured < ActiveRecord::Migration

  def change
    rename_column :courses, :featured_course, :featured
  end
end
