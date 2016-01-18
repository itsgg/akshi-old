class AddLessonIdToSchedules < ActiveRecord::Migration
  def change
    add_column :schedules, :lesson_id, :integer
  end
end
