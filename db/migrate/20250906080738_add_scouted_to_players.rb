class AddScoutedToPlayers < ActiveRecord::Migration[8.0]
  def change
    add_column :players, :scouted, :boolean, default: false
  end
end
