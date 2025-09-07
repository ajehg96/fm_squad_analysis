# frozen_string_literal: true

require "rails_helper"
require_relative "../../app/services/scouted_data_persister"

RSpec.describe(ScoutedDataPersister) do
  let(:persister) { described_class.new }
  let(:today) { Date.new(2025, 9, 7) }

  let(:base_attributes) { DataImporter::PLAYER_ATTRIBUTES.index_with { 10 } }
  let(:processed_squad_data) do
    [
      base_attributes.merge(
        "name" => "Player One",
        "position_string" => "ST (C)",
        "age" => 21,
        "att_fin" => 15,
      ),
      base_attributes.merge(
        "name" => "Player Two",
        "position_string" => "D (C)",
        "age" => 19,
        "att_tck" => 16,
      ),
    ]
  end

  before do
    allow(Date).to(receive(:today).and_return(today))
  end

  # REMOVED: The test that checked for destructive behaviour
  # ("deletes previously scouted players") has been removed as it no longer
  # reflects the intended logic of the service.

  it "creates new players with the scouted flag" do
    persister.persist(processed_squad_data: processed_squad_data)
    expect(Player.where(scouted: true).count).to(eq(2))
    expect(Player.pluck(:name)).to(contain_exactly("Player One", "Player Two"))
  end

  it "creates a snapshot for each new player with the correct data" do
    persister.persist(processed_squad_data: processed_squad_data)
    player_one = Player.find_by!(name: "Player One")
    snapshot = player_one.player_snapshots.first

    expect(player_one.player_snapshots.count).to(eq(1))
    expect(snapshot.snapshot_date).to(eq(today))
    expect(snapshot.position_string).to(eq("ST (C)"))
    expect(snapshot.age).to(eq(21))
    expect(snapshot.att_fin).to(eq(15))
    expect(snapshot.att_tck).to(eq(10))
  end

  it "does not affect non-scouted players" do
    club_player = Player.create!(name: "My Club Player", scouted: false)
    persister.persist(processed_squad_data: processed_squad_data)
    expect(Player.find_by(id: club_player.id)).not_to(be_nil)
  end
end
