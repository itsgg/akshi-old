class AddOfflinePaymentInstructionToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :offline_payment_instruction, :text
  end
end
