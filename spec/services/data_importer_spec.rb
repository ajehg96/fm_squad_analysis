# frozen_string_literal: true

require_relative "../spec_helper"
require_relative "../../app/services/data_importer"

RSpec.describe(DataImporter) do
  let(:importer) { described_class.new }

  describe "#calculate_role_ratings" do
    let(:role_attributes) do
      [
        { "role_code" => "gkskdc_sk_d_c", "att_cor" => 10, "att_cro" => 5 },
        { "role_code" => "cdbpdc_bpd_d_c", "att_cor" => 5, "att_cro" => 10 },
      ]
    end

    let(:squad_data) do
      [
        { "name" => "Player A", "age" => 25, "goal_keeper" => true, "att_cor" => 15, "att_cro" => 10 },
        { "name" => "Player B", "age" => 25, "central_defender" => true, "att_cor" => 10, "att_cro" => 15 },
      ]
    end

    let(:role_ratings) { importer.calculate_role_ratings(squad_data, role_attributes) }

    it "returns ratings for the correct number of players" do
      expect(role_ratings.size).to(eq(2))
    end

    it "calculates ratings correctly for Player A" do
      player_a_rating = role_ratings.find { |p| p["name"] == "Player A" }["gkskdc_sk_d_c"]
      expect(player_a_rating).to(be_within(0.01).of(13.33))
    end

    it "calculates ratings correctly for Player B" do
      player_b_rating = role_ratings.find { |p| p["name"] == "Player B" }["cdbpdc_bpd_d_c"]
      expect(player_b_rating).to(be_within(0.01).of(13.33))
    end
  end

  describe "#calculate_free_role_ratings" do
    let(:role_attributes) do
      [{ "role_code" => "cd_bpd_d_c", "att_tck" => 5, "att_mar" => 5 }]
    end

    let(:squad_data) do
      [
        { "name" => "Young Striker", "age" => 20, "central_defender" => false, "att_tck" => 5, "att_mar" => 5 },
        { "name" => "Senior Striker", "age" => 28, "central_defender" => false, "att_tck" => 5, "att_mar" => 5 },
      ]
    end

    let(:free_ratings) { importer.calculate_free_role_ratings(squad_data, role_attributes) }

    it "does NOT penalize a young player in an unnatural position" do
      young_striker_rating = free_ratings.find { |p| p["name"] == "Young Striker" }["cd_bpd_d_c"]
      expect(young_striker_rating).to(be_within(0.01).of(5.0))
    end

    it "STILL penalizes an older player in an unnatural position" do
      senior_striker_rating = free_ratings.find { |p| p["name"] == "Senior Striker" }["cd_bpd_d_c"]
      expect(senior_striker_rating).to(be_within(0.01).of(1.0))
    end
  end
end
