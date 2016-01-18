class AddCurrencyToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :currency, :string, :default => 'INR'
  end
end
