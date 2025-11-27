class AddValidDeductionToExpense < ActiveRecord::Migration[7.1]
  def change
    add_column :expenses, :valid_deduction, :boolean
  end
end
