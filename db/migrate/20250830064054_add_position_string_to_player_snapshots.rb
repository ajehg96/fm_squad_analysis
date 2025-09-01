# frozen_string_literal: true

class AddPositionStringToPlayerSnapshots < ActiveRecord::Migration[8.0]
  def change
    add_column(:player_snapshots, :position_string, :string)
  end
end
