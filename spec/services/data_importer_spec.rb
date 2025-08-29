require_relative '../spec_helper'
require_relative '../../app/services/data_importer'

RSpec.describe DataImporter do
  let(:importer) { DataImporter.new }
  describe '#calculate_role_ratings' do
    let(:processed_role_attributes) do
      [
        { "role_code" => "gkskdc_sk_d_c", "att_cor" => 10, "att_cro" => 20 },
        { "role_code" => "cdbpdc_bpd_d_c", "att_cor" => 5, "att_cro" => 10 }
      ]
    end

    let(:processed_squad_data) do
      [
        { "name" => "Player A", "position" => "GK", "att_cor" => 5, "att_cro" => 10 },
        { "name" => "Player B", "position" => "CD", "att_cor" => 2, "att_cro" => 5 }
      ]
    end

    let(:role_ratings) { importer.calculate_role_ratings(processed_squad_data, processed_role_attributes) }

    it 'returns the correct number of players' do
      expect(role_ratings.size).to eq(2)
    end

    it 'calculates the rating for the first player' do
      expect(role_ratings[0]["name"]).to eq("Player A")
    end

    it 'calculates the rating for the first player' do
      expect(role_ratings[0]["gkskdc_sk_d_c"]).to be_a(Float)
    end

    it 'calculates the rating for the second player' do
      expect(role_ratings[1]["name"]).to eq("Player B")
    end

    it 'calculates the rating for the second player' do
      expect(role_ratings[1]["cdbpdc_bpd_d_c"]).to be_a(Float)
    end
  end

  describe '#calculate_free_role_ratings' do
    let(:role_attributes) do
      # We'll test against a Central Defender role
      [ { "role_code" => "cd_bpd_d_c", "att_tck" => 5, "att_mar" => 5, "att_fin" => 1 } ]
    end

    let(:squad_data) do
      [
        # A young player who is a natural for the position
        { "name" => "Young CD", "age" => 19, "central_defender" => true, "striker" => false, "att_tck" => 15, "att_mar" => 15, "att_fin" => 5 },
        # A young player who is NOT a natural for the position
        { "name" => "Young Striker", "age" => 20, "central_defender" => false, "striker" => true, "att_tck" => 5, "att_mar" => 5, "att_fin" => 15 },
        # An older player who is NOT a natural for the position
        { "name" => "Senior Striker", "age" => 28, "central_defender" => false, "striker" => true, "att_tck" => 5, "att_mar" => 5, "att_fin" => 15 }
      ]
    end

    let(:free_ratings) { importer.calculate_free_role_ratings(squad_data, role_attributes) }
    let(:standard_ratings) { importer.calculate_role_ratings(squad_data, role_attributes) }

    it 'does NOT penalize a young player in an unnatural position' do
      young_striker_rating = free_ratings.find { |p| p["name"] == "Young Striker" }["cd_bpd_d_c"]

      # The score should be their raw score, which is (5*5 + 5*5 + 15*1) / (5+5+1) = 65 / 11 = 5.909...
      expect(young_striker_rating).to be > 5.9
    end

    it 'STILL penalizes an older player in an unnatural position' do
      senior_striker_rating = free_ratings.find { |p| p["name"] == "Senior Striker" }["cd_bpd_d_c"]
      standard_senior_striker_rating = standard_ratings.find { |p| p["name"] == "Senior Striker" }["cd_bpd_d_c"]

      # The score should be penalized (multiplied by 0.2), just like in the standard calculation
      # Raw score is ~5.9, penalized score is ~1.18
      expect(senior_striker_rating).to be < 1.2
      expect(senior_striker_rating).to eq(standard_senior_striker_rating)
    end
  end
end
