class RemoveDeletedAtFromTopics < ActiveRecord::Migration
  def up
    remove_column :topics, :deleted_at
  end

  def down
    add_column :topics, :deleted_at, :datetime
  end
end
