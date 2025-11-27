class AddCategoryToExpense < ActiveRecord::Migration[7.1]
  def change
    add_column :expenses, :category, :string
  end
end
