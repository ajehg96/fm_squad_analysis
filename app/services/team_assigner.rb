# app/services/team_assigner.rb

require "munkres"
require "set"

class TeamAssigner
  PLAYER_INFO_KEYS = %w[name age potential].freeze

  def assign_first_team(role_ratings, tactic_roles)
    assign_team(role_ratings.dup, tactic_roles)
  end

  def assign_second_team(role_ratings, tactic_roles, first_team)
    remaining_players = role_ratings.reject do |player|
      first_team.any? { |fp| fp[:name] == player["name"] }
    end
    assign_team(remaining_players, tactic_roles)
  end

  def assign_third_team(role_ratings, tactic_roles, first_team, second_team)
    picked_names = (first_team.map { |p| p[:name] } + second_team.map { |p| p[:name] }).to_set

    youth_players = role_ratings.select do |player|
      player["age"] < 22 && !picked_names.include?(player["name"])
    end

    modified_youth_ratings = youth_players.map do |player|
      modifier = player["potential"] / 200.0
      modified_player = { "name" => player["name"], "age" => player["age"] }

      player.each do |key, value|
        next if PLAYER_INFO_KEYS.include?(key)
        modified_player[key] = value * modifier
      end
      modified_player
    end

    assign_team(modified_youth_ratings, tactic_roles)
  end

  def assign_best_roles_for_remainder(role_ratings, first_team, second_team, third_team)
    picked_names = (
      first_team.map { |p| p[:name] } +
      second_team.map { |p| p[:name] } +
      third_team.map { |p| p[:name] }
    ).to_set

    remaining_players = role_ratings.reject { |player| picked_names.include?(player["name"]) }

    remaining_players.map do |player|
      scores_only = player.reject { |key, _| PLAYER_INFO_KEYS.include?(key) }
      best_role, best_score = scores_only.max_by { |_, score| score }

      { name: player["name"], position: best_role, score: best_score }
    end
  end


  private

  def assign_team(players, tactic_roles)
    return [] if players.empty?

    role_codes = tactic_roles.flat_map do |tr|
      [ tr["position"] ] * tr["number"]
    end

    cost_matrix = players.map do |player_ratings|
      role_codes.map { |role_code| player_ratings[role_code] || 0 }
    end

    matrix = cost_matrix.map { |row| row.map(&:to_f) }
    max_score = matrix.flatten.max || 0
    normalized_matrix = matrix.map do |row|
      row.map { |score| max_score - score }
    end

    num_rows = normalized_matrix.size
    num_cols = normalized_matrix.first&.size || 0

    if num_rows > num_cols
      padding_cols = num_rows - num_cols
      normalized_matrix.each do |row|
        padding_cols.times { row << 9999 }
      end
    elsif num_cols > num_rows
      padding_rows = num_cols - num_rows
      padding_rows.times do
        normalized_matrix << Array.new(num_cols, 9999)
      end
    end

    # --- THIS IS THE CORRECTED LINE, BASED ON THE SOURCE CODE ---
    munkres = Munkres.new(normalized_matrix)
    assignments = munkres.find_pairings
    # -----------------------------------------------------------

    team = []
    assignments.each do |row_idx, col_idx|
      next if row_idx >= players.size || col_idx >= role_codes.size

      player = players[row_idx]
      assigned_role_code = role_codes[col_idx]
      score = player[assigned_role_code]

      team << { name: player["name"], position: assigned_role_code, score: score }
    end
    team
  end
end
