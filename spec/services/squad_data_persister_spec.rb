# frozen_string_literal: true

require "rails_helper"

RSpec.describe(SquadDataPersister) do
  let(:service) { described_class.new }
  let(:snapshot_date) { Date.new(2025, 8, 1) }

  # FIXED: Use a base_attributes helper to provide complete, realistic test data
  let(:base_attributes) { DataImporter::PLAYER_ATTRIBUTES.index_with { 10 } }
  let(:player_data) do
    [
      base_attributes.merge(
        "name" => "Test Player 1",
        "position_string" => "ST",
        "age" => 25,
        "att_fin" => 15,
        "att_tck" => 5,
      ),
      base_attributes.merge(
        "name" => "Test Player 2",
        "position_string" => "DM",
        "age" => 22,
        "att_fin" => 10,
        "att_tck" => 10,
      ),
    ]
  end

  describe "#persist" do
    context "when the player is new" do
      it "creates a new Player and a new PlayerSnapshot" do
        expect { service.persist(processed_squad_data: player_data, snapshot_date: snapshot_date) }
          .to(change(Player, :count).by(2)
          .and(change(PlayerSnapshot, :count).by(2)))
      end

      it "correctly saves the attributes and date" do
        service.persist(processed_squad_data: player_data, snapshot_date: snapshot_date)
        snapshot = Player.find_by(name: "Test Player 1").player_snapshots.first
        expect(snapshot).to(have_attributes(
          snapshot_date: snapshot_date,
          age: 25,
          position_string: "ST",
          att_fin: 15,
          att_tck: 5,
        ))
      end
    end

    context "when a player already exists" do
      # Create an existing player with a previous snapshot
      let!(:existing_player) do
        Player.create!(name: "Test Player 1").tap do |p|
          p.player_snapshots.create!(snapshot_date: snapshot_date - 1.month)
        end
      end

      it "finds the existing player and only creates one new player" do
        expect { service.persist(processed_squad_data: player_data, snapshot_date: snapshot_date) }
          .to(change(Player, :count).by(1) # Only Player 2 is new
          .and(change(PlayerSnapshot, :count).by(2))) # Both get a new snapshot
      end

      it "adds a new snapshot to the existing player" do
        # IMPROVED: This test now checks that the snapshot count for the
        # specific player increases by 1, which is more precise.
        expect { service.persist(processed_squad_data: player_data, snapshot_date: snapshot_date) }
          .to(change { existing_player.player_snapshots.count }.by(1))
      end
    end
  end
end
