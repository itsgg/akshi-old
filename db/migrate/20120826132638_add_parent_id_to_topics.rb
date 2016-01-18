class AddParentIdToTopics < ActiveRecord::Migration
  def change
    add_column :topics, :parent_id, :integer
    add_index :topics, :parent_id
  end
end
