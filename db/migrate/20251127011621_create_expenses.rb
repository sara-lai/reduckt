class CreateExpenses < ActiveRecord::Migration[7.1]
  def change
    create_table :expenses do |t|
      t.decimal :amount
      t.text :reason
      t.string :status
      t.references :organisation, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.jsonb :ai_data
      t.string :ai_title

      t.timestamps
    end
  end
end
