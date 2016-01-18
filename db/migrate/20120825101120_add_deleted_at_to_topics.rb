class AddDeletedAtToTopics < ActiveRecord::Migration
  def change
    add_column :topics, :deleted_at, :datetime
  end
end
