class CreateCollections < ActiveRecord::Migration
  def change
    create_table :collections do |t|
      t.string :name
      t.string :ancestry
      t.timestamps
    end
    add_index :collections, :ancestry
  end
end
