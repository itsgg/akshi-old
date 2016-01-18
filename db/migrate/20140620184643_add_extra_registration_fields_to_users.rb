class AddExtraRegistrationFieldsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :phone_number, :string
    add_column :users, :state_city, :string
    add_column :users, :institution, :string
    add_column :users, :date_of_birth, :string
  end
end
