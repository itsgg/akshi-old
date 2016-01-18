class AddOfflinePaymentInstructionToCollections < ActiveRecord::Migration
  def change
    add_column :collections, :offline_payment_instruction, :text
  end
end
