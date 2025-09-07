# frozen_string_literal: true

class SquadDataPersister
  def persist(processed_squad_data:, snapshot_date:)
    player_names_in_file = processed_squad_data.map { |h| h["name"] }

    # STEP 1: Demote/release any players no longer in the squad.
    # Find all players currently in the squad who are NOT in the new file.
    players_to_demote = Player.where(scouted: false).where.not(name: player_names_in_file)
    # Update all of them in a single, efficient query.
    players_to_demote.update_all(scouted: true)

    # STEP 2: Promote or confirm all players who are in the file.
    players_to_persist = processed_squad_data.map do |player_hash|
      Player.new(name: player_hash["name"], scouted: false)
    end

    # Bulk import the players. If a player name already exists (on_duplicate_key),
    # it will just update their 'scouted' status instead of creating a new record.
    Player.import(
      players_to_persist,
      on_duplicate_key_update: {
        conflict_target: [:name], # The unique key to check for conflicts
        columns: [:scouted], # The columns to update if a conflict occurs
      },
    )

    # STEP 3: Create the new snapshots for this date.
    # Re-fetch all players from the file to get their IDs.
    all_players = Player.where(name: player_names_in_file).index_by(&:name)

    snapshots_to_create = []
    snapshot_attrs = player_snapshot_attributes
    processed_squad_data.each do |player_hash|
      player = all_players[player_hash["name"]]
      next unless player

      attributes = player_hash.slice(*snapshot_attrs)
      attributes[:player_id] = player.id
      attributes[:snapshot_date] = snapshot_date
      snapshots_to_create << PlayerSnapshot.new(attributes)
    end

    PlayerSnapshot.import(snapshots_to_create)
  end

  private

  def player_snapshot_attributes
    @player_snapshot_attributes ||= PlayerSnapshot.attribute_names - ["id", "created_at", "updated_at"]
  end
end
