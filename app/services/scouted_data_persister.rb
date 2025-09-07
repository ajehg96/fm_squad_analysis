# frozen_string_literal: true

class ScoutedDataPersister
  def persist(processed_squad_data:)
    # CRITICAL CHANGE: The destructive 'destroy_all' call has been removed.

    # STEP 1: Import or update all players from the file, setting them as 'scouted'.
    players_to_persist = processed_squad_data.map do |player_hash|
      Player.new(name: player_hash["name"], scouted: true)
    end

    Player.import(
      players_to_persist,
      on_duplicate_key_update: {
        conflict_target: [:name],
        columns: [:scouted],
      },
    )

    # STEP 2: Create new snapshots for this scouting run.
    player_names_in_file = processed_squad_data.map { |h| h["name"] }
    all_players = Player.where(name: player_names_in_file).index_by(&:name)

    snapshots_to_create = []
    snapshot_attrs = player_snapshot_attributes
    processed_squad_data.each do |player_hash|
      player = all_players[player_hash["name"]]
      next unless player

      attributes = player_hash.slice(*snapshot_attrs)
      attributes[:player_id] = player.id
      attributes[:snapshot_date] = Time.zone.today
      snapshots_to_create << PlayerSnapshot.new(attributes)
    end

    PlayerSnapshot.import(snapshots_to_create)
  end

  private

  def player_snapshot_attributes
    @player_snapshot_attributes ||= PlayerSnapshot.attribute_names - ["id", "created_at", "updated_at"]
  end
end
