class CreateSites < ActiveRecord::Migration
  def change
    create_table :sites do |t|
      t.boolean :broadcasting, :default => false
      t.timestamps
    end
  end
end
