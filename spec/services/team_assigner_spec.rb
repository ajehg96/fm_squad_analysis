require_relative '../spec_helper'
require_relative '../../app/services/data_importer'
require_relative '../../app/services/team_assigner'

RSpec.describe 'TeamAssigner' do
  let(:processed_role_attributes) do
    [
      { "role_code" => "gkskdc_sk_d_c", "att_cor" => 10, "att_cro" => 20 },
      { "role_code" => "cdbpdc_bpd_d_c", "att_cor" => 5, "att_cro" => 10 }
    ]
  end

  let(:processed_squad_data) do
    [
      # Players for First Team
      { "name" => "Player A (GK)", "age" => 25, "potential" => 150, "goal_keeper" => true, "att_cor" => 18, "att_cro" => 10 },
      { "name" => "Player D (CD)", "age" => 28, "potential" => 160, "central_defender" => true, "att_cor" => 8, "att_cro" => 15 },
      # Players for Second Team
      { "name" => "Player C (GK)", "age" => 24, "potential" => 140, "goal_keeper" => true, "att_cor" => 12, "att_cro" => 8 },
      { "name" => "Player B (CD)", "age" => 23, "potential" => 155, "central_defender" => true, "att_cor" => 7, "att_cro" => 12 },
      # Youth Players for Third Team
      { "name" => "Youth A (GK)", "age" => 18, "potential" => 180, "goal_keeper" => true, "att_cor" => 8, "att_cro" => 5 },
      { "name" => "Youth B (CD)", "age" => 19, "potential" => 130, "central_defender" => true, "att_cor" => 6, "att_cro" => 10 },
      # Leftover Players
      { "name" => "Leftover A (GK)", "age" => 29, "potential" => 110, "goal_keeper" => true, "att_cor" => 1, "att_cro" => 1 },
      { "name" => "Leftover B (CD)", "age" => 20, "potential" => 115, "central_defender" => true, "att_cor" => 1, "att_cro" => 2 }
    ]
  end

  let(:tactic_roles) do
    [
      { "position" => "gkskdc_sk_d_c", "number" => 1 },
      { "position" => "cdbpdc_bpd_d_c", "number" => 1 }
    ]
  end

  let(:role_ratings) do
    importer = DataImporter.new
    importer.calculate_role_ratings(processed_squad_data, processed_role_attributes)
  end

  let(:assigner) { TeamAssigner.new }

  describe '#assign_first_team' do
    let(:first_team) { assigner.assign_first_team(role_ratings, tactic_roles) }

    it 'assigns the correct number of players' do
      expect(first_team.size).to eq(2)
    end

    it 'assigns the correct players' do
      expect(first_team.map { |p| p[:name] }).to contain_exactly('Player A (GK)', 'Player D (CD)')
    end

    it 'assigns the correct positions' do
      expect(first_team.map { |p| p[:position] }).to contain_exactly('gkskdc_sk_d_c', 'cdbpdc_bpd_d_c')
    end
  end

  describe '#assign_second_team' do
    let(:first_team) { assigner.assign_first_team(role_ratings, tactic_roles) }
    let(:second_team) { assigner.assign_second_team(role_ratings, tactic_roles, first_team) }

    it 'assigns the correct number of players' do
      expect(second_team.size).to eq(2)
    end

    it 'assigns the correct players' do
      expect(second_team.map { |p| p[:name] }).to contain_exactly('Player B (CD)', 'Player C (GK)')
    end

    it 'assigns the correct positions' do
      expect(second_team.map { |p| p[:position] }).to contain_exactly('gkskdc_sk_d_c', 'cdbpdc_bpd_d_c')
    end
  end

  describe '#assign_third_team' do
    let(:first_team) { assigner.assign_first_team(role_ratings, tactic_roles) }
    let(:second_team) { assigner.assign_second_team(role_ratings, tactic_roles, first_team) }
    let(:third_team) { assigner.assign_third_team(role_ratings, tactic_roles, first_team, second_team) }

    it 'assigns the correct number of players' do
      expect(third_team.size).to eq(2)
    end

    it 'only assigns players under the age of 22' do
      third_team_names = third_team.map { |p| p[:name] }
      original_players = processed_squad_data.select { |p| third_team_names.include?(p["name"]) }
      expect(original_players.all? { |p| p["age"] < 22 }).to be true
    end

    it 'assigns players based on potential-modified scores' do
      expect(third_team.map { |p| p[:name] }).to contain_exactly('Youth A (GK)', 'Youth B (CD)')
    end

    it 'does not assign players already in the first or second teams' do
      first_and_second_team_names = (first_team + second_team).map { |p| p[:name] }
      expect(third_team.none? { |p| first_and_second_team_names.include?(p[:name]) }).to be true
    end
  end
end
