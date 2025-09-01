# frozen_string_literal: true

class AddFootStrengthToPlayerSnapshots < ActiveRecord::Migration[8.0]
  def change
    add_column(:player_snapshots, :foot_right, :integer)
    add_column(:player_snapshots, :foot_left, :integer)
  end
end
