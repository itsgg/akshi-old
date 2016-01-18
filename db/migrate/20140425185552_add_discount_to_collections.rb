class AddDiscountToCollections < ActiveRecord::Migration
  def change
    add_column :collections, :discount, :integer
  end
end
