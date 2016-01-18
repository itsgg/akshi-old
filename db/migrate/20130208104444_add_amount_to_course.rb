class AddAmountToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :amount, :float, :default => 0
  end
end
