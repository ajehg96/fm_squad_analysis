# frozen_string_literal: true

require "rails_helper"

RSpec.describe(SquadDataPersister) do
  let(:service) { described_class.new }
  let(:snapshot_date) { Date.new(2025, 8, 1) }
  let(:player_data) do
    [
      { "name" => "Test Player 1", "att_fin" => 15, "att_tck" => 5 },
      { "name" => "Test Player 2", "att_fin" => 10, "att_tck" => 10 },
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
        expect(snapshot).to(have_attributes(snapshot_date: snapshot_date, att_fin: 15, att_tck: 5))
      end
    end

    context "when a player already exists" do
      # Create an existing player before the test runs
      let!(:existing_player) { Player.create!(name: "Test Player 1") }

      it "finds the existing player and only creates a new snapshot" do
        expect { service.persist(processed_squad_data: player_data, snapshot_date: snapshot_date) }
          .to(change(Player, :count).by(1) # Only Player 2 is new
          .and(change(PlayerSnapshot, :count).by(2))) # Both get a new snapshot
      end

      it "creates a second snapshot for the existing player" do
        service.persist(processed_squad_data: player_data, snapshot_date: snapshot_date)
        expect(existing_player.player_snapshots.count).to(eq(1))
      end
    end
  end
end
