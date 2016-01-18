class AddStatusToCourse < ActiveRecord::Migration
  def change
  	add_column :courses, :status, :string, :default => "new"
  end
end
