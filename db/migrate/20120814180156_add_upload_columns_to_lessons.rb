class AddUploadColumnsToLessons < ActiveRecord::Migration
  def self.up
    add_attachment :lessons, :upload
  end

  def self.down
    remove_attachment :lessons, :upload
  end
end
