class AddAverageScoreToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :average_score, :float, :default => 0, :null => false
  end
end
