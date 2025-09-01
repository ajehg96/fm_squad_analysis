# frozen_string_literal: true

require "rails_helper"

RSpec.describe(PlayerProgression) do
  let(:player) { Player.create!(name: "Test Player") }
  let(:base_attributes) { DataImporter::PLAYER_ATTRIBUTES.index_with { 0 } }
  let(:progression) { described_class.new(player) }

  before do
    player.player_snapshots.create!(base_attributes.merge(snapshot_date: "2025-01-01", att_fin: 10, att_tck: 5))
    player.player_snapshots.create!(base_attributes.merge(snapshot_date: "2025-02-01", att_fin: 12, att_tck: 6))
    player.player_snapshots.create!(base_attributes.merge(snapshot_date: "2025-03-01", att_fin: 15, att_tck: 5))
  end

  describe "#joined_date" do
    it "returns the date of the first snapshot" do
      expect(progression.joined_date).to(eq(Date.new(2025, 1, 1)))
    end
  end

  describe "#attribute_changes" do
    it "calculates the current value for an attribute" do
      expect(progression.attribute_changes[:att_fin][:current_value]).to(eq(15))
    end

    it "calculates a positive change since the previous snapshot" do
      expect(progression.attribute_changes[:att_fin][:change_since_previous]).to(eq(3))
    end

    it "calculates a negative change since the previous snapshot" do
      expect(progression.attribute_changes[:att_tck][:change_since_previous]).to(eq(-1))
    end

    it "calculates a positive change since the first snapshot" do
      expect(progression.attribute_changes[:att_fin][:change_since_first]).to(eq(5))
    end

    it "calculates a zero change since the first snapshot" do
      expect(progression.attribute_changes[:att_tck][:change_since_first]).to(eq(0))
    end
  end
end
