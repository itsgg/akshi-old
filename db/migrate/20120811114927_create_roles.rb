class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.string :name
      t.references :user
      t.references :course

      t.timestamps
    end
    add_index :roles, :user_id
    add_index :roles, :course_id
  end
end
