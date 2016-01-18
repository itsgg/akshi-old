class AddModeToSchedules < ActiveRecord::Migration
  def change
    add_column :schedules, :mode, :string, :default => 'LIVE'
  end
end
