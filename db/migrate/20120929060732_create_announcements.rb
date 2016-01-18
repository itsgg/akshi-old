class CreateAnnouncements < ActiveRecord::Migration
  def change
    create_table :announcements do |t|
      t.text :content
      t.references :course
      t.references :user
      t.timestamps
    end
  end
end
