# frozen_string_literal: true

class SquadAnalysisReport
  # The view will be able to access all of these instance variables
  attr_reader :tactic,
    :snapshot_date,
    :first_team,
    :second_team,
    :third_team,
    :remainder,
    :balanced_team_a,
    :balanced_team_b,
    :players_by_name,
    :roles_by_code # <-- ADD THIS ATTR_READER

  def initialize(tactic:)
    @tactic = tactic
    @players_by_name = {}
    # The 'analyze' method is called immediately to perform all the calculations
    analyze
  end

  private

  def analyze
    dates = PlayerSnapshot.joins(:player).where(players: { scouted: false }).order(snapshot_date: :desc).select(:snapshot_date).distinct.limit(2)
    @snapshot_date = dates.first&.snapshot_date
    # If there's no data, we can stop here. The view will show a message.
    return unless @snapshot_date

    previous_date = dates.second&.snapshot_date
    role_attributes = RoleData.all_roles

    # ADD THIS LINE to create the lookup hash the view needs
    @roles_by_code = role_attributes.index_by(&:role_code)

    # Calculate ratings for the most recent data
    role_ratings = calculate_ratings_for_date(@snapshot_date, role_attributes)

    # Assign all the teams
    assign_teams(role_ratings, role_attributes)

    # If a previous snapshot exists, calculate rating diffs
    add_rating_diffs(previous_date, role_attributes) if previous_date

    # Finally, load the Player records needed for the view
    load_player_models
  end

  # This helper method contains the team assignment logic
  def assign_teams(role_ratings, role_attributes)
    tactic_for_assigner = build_tactic_for_assigner
    assigner = TeamAssigner.new

    @first_team = assigner.assign_first_team(role_ratings, tactic_for_assigner)
    @second_team = assigner.assign_second_team(role_ratings, tactic_for_assigner, @first_team)
    @third_team = assigner.assign_third_team(role_ratings, tactic_for_assigner, @first_team, @second_team)
    @remainder = assigner.assign_best_roles_for_remainder(role_ratings, @first_team, @second_team, @third_team, tactic_for_assigner)
    @balanced_team_a, @balanced_team_b = assigner.create_balanced_teams(@first_team, @second_team)
  end

  # This helper handles calculating rating improvements/declines
  def add_rating_diffs(previous_date, role_attributes)
    previous_role_ratings = calculate_ratings_for_date(previous_date, role_attributes)
    previous_ratings_map = previous_role_ratings.index_by { |p| p["name"] }

    # Iterate over all the teams we've created
    [@first_team, @second_team, @third_team, @balanced_team_a, @balanced_team_b].each do |team|
      team.each do |player|
        previous_player_ratings = previous_ratings_map[player[:name]]
        if previous_player_ratings
          previous_rating = previous_player_ratings[player[:position]]
          player[:rating_diff] = player[:score] - previous_rating if previous_rating
        end
      end
    end
  end

  # Fetches ratings for a specific date
  def calculate_ratings_for_date(date, role_attributes)
    importer = DataImporter.new
    snapshots = PlayerSnapshot.joins(:player).where(players: { scouted: false }, snapshot_date: date).includes(:player)
    squad_data = importer.process_database_snapshots(snapshots)
    importer.calculate_role_ratings(squad_data, role_attributes)
  end

  # Loads all Player models needed by the view in a single query
  def load_player_models
    all_player_names = [
      @first_team.map { |p| p[:name] },
      @second_team.map { |p| p[:name] },
      @third_team.map { |p| p[:name] },
      @remainder.map { |p| p[:name] },
    ].flatten.uniq

    @players_by_name = Player.where(name: all_player_names).index_by(&:name)
  end

  # Builds the hash structure required by the TeamAssigner service
  def build_tactic_for_assigner
    @tactic.tactic_roles
      .group_by(&:role)
      .map { |role, roles| { "position" => role, "number" => roles.count } }
  end
end
