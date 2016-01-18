class AddDiscussionNotificationToUsers < ActiveRecord::Migration
  def change
    add_column :users, :discussion_notify, :boolean, :default => true
  end
end
