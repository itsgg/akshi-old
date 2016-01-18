class AddPublishedToLessons < ActiveRecord::Migration
  def change
    add_column :lessons, :published, :boolean, :default => false
  end
end
