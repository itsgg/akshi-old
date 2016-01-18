class AddOpentokSessionToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :opentok_session, :string, :default => nil
  end
end
