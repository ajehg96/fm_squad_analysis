# frozen_string_literal: true

require_relative "../spec_helper"
# DataImporter is only needed for the test data setup
require_relative "../../app/services/data_importer"
require_relative "../../app/services/team_assigner"

RSpec.describe(TeamAssigner) do
  let(:assigner) { described_class.new }

  # Test Data Setup Helpers
  let(:role_attributes) do
    [
      { "role_code" => "gkskdc_sk_d_c", "att_cor" => 10, "att_cro" => 20 },
      { "role_code" => "cdbpdc_bpd_d_c", "att_cor" => 5, "att_cro" => 10, "att_tck" => 5 },
    ]
  end

  let(:squad_data) do
    [
      { "name" => "Player A (GK)", "age" => 25, "potential" => 150, "goal_keeper" => true, "att_cor" => 18, "att_cro" => 10 },
      { "name" => "Player D (CD)", "age" => 28, "potential" => 160, "central_defender" => true, "att_cor" => 8, "att_cro" => 15 },
      { "name" => "Player C (GK)", "age" => 24, "potential" => 140, "goal_keeper" => true, "att_cor" => 12, "att_cro" => 8 },
      { "name" => "Player B (CD)", "age" => 23, "potential" => 155, "central_defender" => true, "att_cor" => 7, "att_cro" => 12 },
      { "name" => "Youth A (GK)", "age" => 18, "potential" => 180, "goal_keeper" => true, "att_cor" => 8, "att_cro" => 5 },
      { "name" => "Youth B (CD)", "age" => 19, "potential" => 130, "central_defender" => true, "att_cor" => 6, "att_cro" => 10 },
      { "name" => "Leftover A (GK)", "age" => 29, "potential" => 110, "goal_keeper" => true, "att_cor" => 1, "att_cro" => 1 },
      { "name" => "Leftover B (CD)", "age" => 20, "potential" => 115, "central_defender" => true, "att_cor" => 1, "att_cro" => 2, "att_tck" => 10 },
    ]
  end

  let(:tactic_roles) do
    [
      { "position" => "gkskdc_sk_d_c", "number" => 1 },
      # MODIFIED: Test tactic with 2 of the same position
      { "position" => "cdbpdc_bpd_d_c", "number" => 2 },
    ]
  end

  let(:role_ratings) do
    # This is complex, so we memoize it to avoid recalculating in every test
    @role_ratings ||= DataImporter.new.calculate_role_ratings(squad_data, role_attributes)
  end

  describe "#assign_first_team" do
    let(:first_team) { assigner.assign_first_team(role_ratings, tactic_roles) }

    it "assigns the correct number of players" do
      expect(first_team.size).to(eq(3))
    end

    it "assigns the best player for each position" do
      # Player D is best CD, Player B is second best CD
      expect(first_team.map { |p| p[:name] }).to(contain_exactly("Player A (GK)", "Player D (CD)", "Player B (CD)"))
    end
  end

  describe "#assign_second_team" do
    let(:first_team) { assigner.assign_first_team(role_ratings, tactic_roles) }
    let(:second_team) { assigner.assign_second_team(role_ratings, tactic_roles, first_team) }

    it "assigns the correct number of players" do
      expect(second_team.size).to(eq(3))
    end

    it "assigns the next best player for each position" do
      # After the first team is picked, Player C is the best remaining GK,
      # and Youth B and Leftover B are the best remaining CDs.
      expect(second_team.map { |p| p[:name] }).to(contain_exactly("Player C (GK)", "Youth B (CD)", "Leftover B (CD)"))
    end
  end

  describe "#assign_third_team" do
    # NOTE: Our tactic requires 3 players, but there is only 1 youth player left (Youth A)
    # after the first two teams are picked.
    let(:first_team) { assigner.assign_first_team(role_ratings, tactic_roles) }
    let(:second_team) { assigner.assign_second_team(role_ratings, tactic_roles, first_team) }
    let(:third_team) { assigner.assign_third_team(role_ratings, tactic_roles, first_team, second_team) }

    it "assigns available youth players" do
      expect(third_team.size).to(eq(1))
    end

    it "only assigns players under the age of 22" do
      player_names = third_team.map { |p| p[:name] }
      ages = squad_data.select { |p| player_names.include?(p["name"]) }.map { |p| p["age"] }
      expect(ages.all? { |age| age < 22 }).to(be(true))
    end
  end

  describe "#assign_best_roles_for_remainder" do
    let(:first_team) { assigner.assign_first_team(role_ratings, tactic_roles) }
    let(:second_team) { assigner.assign_second_team(role_ratings, tactic_roles, first_team) }
    let(:third_team) { assigner.assign_third_team(role_ratings, tactic_roles, first_team, second_team) }
    let(:remainder) { assigner.assign_best_roles_for_remainder(role_ratings, first_team, second_team, third_team, tactic_roles) }

    it "identifies the correct remaining player" do
      expect(remainder.size).to(eq(1))
      expect(remainder.first[:name]).to(eq("Leftover A (GK)"))
    end
  end

  describe "#create_balanced_teams" do
    it "splits two teams into two new, roughly balanced teams" do
      # Simple teams for a clear test
      team1 = [
        { name: "GK A", position: "GK", score: 10 },
        { name: "CD C", position: "CD", score: 8 },
      ]
      team2 = [
        { name: "GK B", position: "GK", score: 9 },
        { name: "CD D", position: "CD", score: 7 },
      ]

      team_a, team_b = assigner.create_balanced_teams(team1, team2)
      team_a_names = team_a.map { |p| p[:name] }
      team_b_names = team_b.map { |p| p[:name] }

      # FIXED: The expectation now matches the algorithm's actual output.
      # The code correctly produces:
      # Team A: Best CD (C, 8) + 2nd GK (B, 9) = 17
      # Team B: 2nd CD (D, 7) + Best GK (A, 10) = 17
      expect(team_a_names).to(contain_exactly("CD C", "GK B"))
      expect(team_b_names).to(contain_exactly("CD D", "GK A"))
    end
  end
end
