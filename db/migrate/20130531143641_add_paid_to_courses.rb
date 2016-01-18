class AddPaidToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :paid, :boolean, :default => false
  end
end
