class RenameOrdinalToPosition < ActiveRecord::Migration
  def change
    rename_column :categories, :ordinal, :position
    rename_column :lessons, :ordinal, :position
  end
end
