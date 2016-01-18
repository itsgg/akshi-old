class AddSessionIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :session_id, :text
  end
end
