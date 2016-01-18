class AddCoverColumnsToCollections < ActiveRecord::Migration
  def self.up
    add_attachment :collections, :cover
  end

  def self.down
    remove_attachment :collections, :cover
  end
end
