require_relative '../spec_helper'
require_relative '../../app/services/data_importer'

RSpec.describe DataImporter do
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

    let(:importer) { DataImporter.new }
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
end