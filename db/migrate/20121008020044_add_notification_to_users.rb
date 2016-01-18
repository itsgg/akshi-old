class AddNotificationToUsers < ActiveRecord::Migration
  def change
    add_column :users, :announcement_notify, :boolean, :default => true
  end
end
