class RemoveOpentokSessionFromCourses < ActiveRecord::Migration
  def up
    remove_column :courses, :opentok_session
  end

  def down
    add_column :courses, :opentok_session, :string, :default => nil
  end
end
