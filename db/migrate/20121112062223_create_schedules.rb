class CreateSchedules < ActiveRecord::Migration
  def change
    create_table :schedules do |t|
      t.string :description
      t.datetime :start_time
      t.references :course
      t.timestamps
    end
  end
end
