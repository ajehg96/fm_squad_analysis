# frozen_string_literal: true

class ScoutedPlayersController < ApplicationController
  def index
    @tactics = Tactic.includes(:tactic_roles).all
    session[:selected_tactic_id] = params[:tactic_id] if params[:tactic_id]
    tactic_id = session[:selected_tactic_id] || @tactics.first.id
    @selected_tactic = @tactics.find { |t| t.id == tactic_id.to_i }
    @unique_tactic_roles = @selected_tactic.tactic_roles.uniq(&:role)

    role_attributes = RoleData.all_roles
    @roles_by_code = role_attributes.index_by(&:role_code)

    # --- FIXED QUERY ---
    # STEP 1: Get the IDs of the latest snapshot for each player. This query is now
    # designed to ONLY return IDs, which is what the main query needs.
    latest_snapshot_ids = PlayerSnapshot.select("DISTINCT ON (player_id) id")
      .order(:player_id, snapshot_date: :desc)
      .pluck(:id)

    # STEP 2: Use those IDs to load the scouted players and their associated (latest) snapshot.
    # The 'includes' here pre-loads the data to prevent N+1 queries.
    @scouted_players = Player.where(scouted: true)
      .includes(:player_snapshots)
      .where(player_snapshots: { id: latest_snapshot_ids })

    importer = DataImporter.new
    @scouted_players_data = @scouted_players.map do |player|
      latest_snapshot = player.player_snapshots.first
      next unless latest_snapshot

      squad_data = importer.process_database_snapshots([latest_snapshot])
      role_ratings = importer.calculate_role_ratings(squad_data, role_attributes)

      { player: player, ratings: role_ratings.first, age: latest_snapshot.age }
    end.compact

    if params[:sort_by]
      sort_by = params[:sort_by]
      sort_direction = params.fetch(:sort_direction, "desc") == "desc" ? -1 : 1

      @scouted_players_data.sort_by! do |player_data|
        (player_data[:ratings][sort_by] || 0) * sort_direction
      end
    end
  end

  def new
    # Renders the upload form
  end

  def create
    handle_file_upload
    redirect_to(scouted_players_path, notice: "Scouted players file was successfully uploaded.")
  end

  private

  def handle_file_upload
    return unless params[:scouted_file]

    importer = DataImporter.new
    persister = ScoutedDataPersister.new
    scouted_file_path = params[:scouted_file].path

    raw_squad = importer.import_squad(scouted_file_path)
    processed_data = importer.process_squad_data(raw_squad)
    persister.persist(processed_squad_data: processed_data)
  end
end
