class AddSubjectToAnnouncements < ActiveRecord::Migration
  def change
    add_column :announcements, :subject_id, :integer
  end
end
