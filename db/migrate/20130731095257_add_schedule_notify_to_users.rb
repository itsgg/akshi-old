class AddScheduleNotifyToUsers < ActiveRecord::Migration
  def change
    add_column :users, :schedule_notify, :boolean, :default => true
  end
end
