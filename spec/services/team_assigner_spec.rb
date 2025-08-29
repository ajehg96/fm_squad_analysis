# frozen_string_literal: true

require_relative "../spec_helper"
require_relative "../../app/services/data_importer"
require_relative "../../app/services/team_assigner"

# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe(TeamAssigner) do
  let(:importer) { DataImporter.new }
  let(:assigner) { described_class.new }
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
      { "position" => "cdbpdc_bpd_d_c", "number" => 1 },
    ]
  end
  let(:role_ratings) { importer.calculate_role_ratings(squad_data, role_attributes) }

  describe "#assign_first_team" do
    let(:first_team) { assigner.assign_first_team(role_ratings, tactic_roles) }

    it "assigns the correct number of players" do
      expect(first_team.size).to(eq(2))
    end

    it "assigns the correct players" do
      expect(first_team.map { |p| p[:name] }).to(contain_exactly("Player A (GK)", "Player D (CD)"))
    end

    it "assigns the correct positions" do
      expect(first_team.map { |p| p[:position] }).to(contain_exactly("gkskdc_sk_d_c", "cdbpdc_bpd_d_c"))
    end
  end

  describe "#assign_second_team" do
    let(:first_team) { assigner.assign_first_team(role_ratings, tactic_roles) }
    let(:second_team) { assigner.assign_second_team(role_ratings, tactic_roles, first_team) }

    it "assigns the correct number of players" do
      expect(second_team.size).to(eq(2))
    end

    it "assigns the correct players" do
      expect(second_team.map { |p| p[:name] }).to(contain_exactly("Player B (CD)", "Player C (GK)"))
    end

    it "assigns the correct positions" do
      expect(second_team.map { |p| p[:position] }).to(contain_exactly("gkskdc_sk_d_c", "cdbpdc_bpd_d_c"))
    end
  end

  describe "#assign_third_team" do
    let(:first_team) { assigner.assign_first_team(role_ratings, tactic_roles) }
    let(:second_team) { assigner.assign_second_team(role_ratings, tactic_roles, first_team) }
    let(:third_team) { assigner.assign_third_team(role_ratings, tactic_roles, first_team, second_team) }

    it "assigns the correct number of players" do
      expect(third_team.size).to(eq(2))
    end

    it "only assigns players under the age of 22" do
      ages = squad_data.select { |p| third_team.map { |tp| tp[:name] }.include?(p["name"]) }.map { |p| p["age"] }
      expect(ages.all? { |age| age < 22 }).to(be(true))
    end

    it "assigns players based on potential-modified scores" do
      expect(third_team.map { |p| p[:name] }).to(contain_exactly("Youth A (GK)", "Youth B (CD)"))
    end
  end

  describe "#assign_best_roles_for_remainder" do
    let(:first_team) { assigner.assign_first_team(role_ratings, tactic_roles) }
    let(:second_team) { assigner.assign_second_team(role_ratings, tactic_roles, first_team) }
    let(:third_team) { assigner.assign_third_team(role_ratings, tactic_roles, first_team, second_team) }
    let(:remainder) { assigner.assign_best_roles_for_remainder(role_ratings, first_team, second_team, third_team) }

    it "identifies the correct number of remaining players" do
      expect(remainder.size).to(eq(2))
    end

    it "identifies the correct remaining players by name" do
      expect(remainder.map { |p| p[:name] }).to(contain_exactly("Leftover A (GK)", "Leftover B (CD)"))
    end

    it "finds the single best position for 'Leftover A (GK)'" do
      leftover_a = remainder.find { |p| p[:name] == "Leftover A (GK)" }

      expect(leftover_a[:position]).to(eq("gkskdc_sk_d_c"))
    end

    it "finds the single best position for 'Leftover B (CD)'" do
      leftover_b = remainder.find { |p| p[:name] == "Leftover B (CD)" }

      expect(leftover_b[:position]).to(eq("cdbpdc_bpd_d_c"))
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
