# frozen_string_literal: true

class AddHeightAndPotentialToPlayerSnapshots < ActiveRecord::Migration[8.0]
  def change
    add_column(:player_snapshots, :height, :integer)
    add_column(:player_snapshots, :potential, :integer)
  end
end
