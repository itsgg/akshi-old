class AddOrdinalToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :ordinal, :integer
  end
end
