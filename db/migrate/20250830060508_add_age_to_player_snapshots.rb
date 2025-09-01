# frozen_string_literal: true

class AddAgeToPlayerSnapshots < ActiveRecord::Migration[8.0]
  def change
    add_column(:player_snapshots, :age, :integer)
  end
end
