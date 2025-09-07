# frozen_string_literal: true

# app/services/team_assigner.rb

require "munkres"
require "set"

class TeamAssigner
  PLAYER_INFO_KEYS = ["name", "age", "potential"].freeze

  def assign_first_team(role_ratings, tactic_roles)
    # Refactored to use the new private helper method
    assign_team_greedily(role_ratings, tactic_roles, Set.new)
  end

  def assign_second_team(role_ratings, tactic_roles, first_team)
    # Refactored to use the new private helper method
    assigned_player_names = first_team.map { |p| p[:name] }.to_set
    assign_team_greedily(role_ratings, tactic_roles, assigned_player_names)
  end

  def assign_third_team(role_ratings, tactic_roles, first_team, second_team)
    assigned_player_names = Set.new(first_team.map { |p| p[:name] } + second_team.map { |p| p[:name] })
    flatten_tactic_roles(tactic_roles)

    youth_players = role_ratings.select do |player|
      player["age"] < 22 && !assigned_player_names.include?(player["name"])
    end

    # Apply potential modifier to youth players' ratings
    modified_youth_ratings = youth_players.map do |player|
      modifier = player["potential"] / 200.0
      modified_player = { "name" => player["name"], "age" => player["age"] }

      player.each do |key, value|
        next if PLAYER_INFO_KEYS.include?(key)

        modified_player[key] = value * modifier
      end
      modified_player
    end

    # Use the same greedy assignment, but with the modified youth data
    assign_team_greedily(modified_youth_ratings, tactic_roles, assigned_player_names)
  end

  # FIXED: Added the missing 'tactic_roles' argument to the method signature.
  def assign_best_roles_for_remainder(role_ratings, first_team, second_team, third_team, tactic_roles)
    picked_names = (
      first_team.map { |p| p[:name] } +
      second_team.map { |p| p[:name] } +
      third_team.map { |p| p[:name] }
    ).to_set

    remaining_players = role_ratings.reject { |player| picked_names.include?(player["name"]) }
    tactic_positions = tactic_roles.map { |r| r["position"] }.to_set

    remaining_players.map do |player|
      scores_only = player.select { |key, _| tactic_positions.include?(key) }
      best_role, best_score = scores_only.max_by { |_, score| score }

      { name: player["name"], position: best_role, score: best_score }
    end
  end

  def create_balanced_teams(first_team, second_team)
    combined_players_by_position = {} # Hash to store players grouped by their assigned position

    (first_team + second_team).each do |player|
      combined_players_by_position[player[:position]] ||= []
      combined_players_by_position[player[:position]] << player
    end

    team_a = []
    team_b = []
    team_a_score = 0
    team_b_score = 0

    # Sort positions to ensure deterministic behaviour in tests
    sorted_positions = combined_players_by_position.keys.sort
    sorted_positions.each do |position|
      players_in_position = combined_players_by_position[position]
      sorted_players = players_in_position.sort_by { |p| -p[:score] } # Sort by score descending

      sorted_players.each do |player|
        if team_a_score <= team_b_score
          team_a << player
          team_a_score += player[:score]
        else
          team_b << player
          team_b_score += player[:score]
        end
      end
    end

    [team_a, team_b]
  end

  private

  def flatten_tactic_roles(tactic_roles)
    tactic_roles.flat_map do |tr|
      [tr["position"]] * tr["number"]
    end
  end

  # This new private method contains the logic that was duplicated
  def assign_team_greedily(ratings, tactic_roles, excluded_player_names)
    team = []
    # Use a copy of the set so we don't modify the original
    assigned_player_names = excluded_player_names.dup
    required_positions = flatten_tactic_roles(tactic_roles)

    required_positions.each do |position_code|
      best_player_for_role = ratings.reject { |p| assigned_player_names.include?(p["name"]) }
        .max_by { |p| p[position_code] || 0 }

      if best_player_for_role
        team << { name: best_player_for_role["name"], position: position_code, score: best_player_for_role[position_code] }
        assigned_player_names << best_player_for_role["name"]
      end
    end
    team
  end
end
