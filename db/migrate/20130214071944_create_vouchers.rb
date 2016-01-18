class CreateVouchers < ActiveRecord::Migration
  def change
    create_table :vouchers do |t|
      t.string :code
      t.string :status, :default => 'new'
      t.references :course
      t.references :user
      t.timestamps
    end
  end
end
