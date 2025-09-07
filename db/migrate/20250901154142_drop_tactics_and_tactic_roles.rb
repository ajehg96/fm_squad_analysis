class DropTacticsAndTacticRoles < ActiveRecord::Migration[7.0]
  def change
    drop_table :tactic_roles
    drop_table :tactics
  end
end