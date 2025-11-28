class AddHasReimbursedToExpense < ActiveRecord::Migration[7.1]
  def change
    add_column :expenses, :has_reimbursed, :boolean
  end
end
