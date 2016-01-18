class AddPaidToCollections < ActiveRecord::Migration
  def change
    add_column :collections, :paid, :boolean, :default => false
  end
end
