class CreateTacticRoles < ActiveRecord::Migration[8.0]
  def change
    create_table :tactic_roles do |t|
      t.references :tactic, null: false, foreign_key: true
      t.integer :position
      t.string :role

      t.timestamps
    end
  end
end
