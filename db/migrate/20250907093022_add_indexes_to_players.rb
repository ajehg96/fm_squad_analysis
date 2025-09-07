# frozen_string_literal: true

class AddIndexesToPlayers < ActiveRecord::Migration[8.0]
  def change
    add_index :players, :scouted
    add_index :players, :name, unique: true
  end
end