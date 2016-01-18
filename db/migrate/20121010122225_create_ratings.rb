class CreateRatings < ActiveRecord::Migration
  def change
    create_table :ratings do |t|
      t.references :owner
      t.references :ratable, :polymorphic => true
      t.float :score
      t.timestamps
    end
  end
end
