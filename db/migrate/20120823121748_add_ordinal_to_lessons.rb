class AddOrdinalToLessons < ActiveRecord::Migration
  def change
    add_column :lessons, :ordinal, :integer
  end
end
