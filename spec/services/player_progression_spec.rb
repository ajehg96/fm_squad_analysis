# frozen_string_literal: true

require "rails_helper"
require_relative "../../app/services/role_data" # Require the new service

RSpec.describe(PlayerProgression) do
  let(:player) { Player.create!(name: "Test Player") }
  let(:base_attributes) { DataImporter::PLAYER_ATTRIBUTES.index_with { 0 } }

  context "with a player who has multiple snapshots" do
    let(:progression) { described_class.new(player) }

    before do
      player.player_snapshots.create!(base_attributes.merge(snapshot_date: "2025-01-01", att_fin: 10, att_tck: 5))
      player.player_snapshots.create!(base_attributes.merge(snapshot_date: "2025-02-01", att_fin: 12, att_tck: 6))
      # FIXED: Ensure the latest snapshot has the data needed for the goalkeeper? test
      player.player_snapshots.create!(base_attributes.merge(snapshot_date: "2025-03-01", att_fin: 15, att_tck: 5, position_string: "ST (C)"))
    end

    describe "#joined_date" do
      it "returns the date of the first snapshot" do
        expect(progression.joined_date).to(eq(Date.new(2025, 1, 1)))
      end
    end

    describe "#technical_attributes" do
      it "calculates the current value for an attribute" do
        expect(progression.technical_attributes[:att_fin][:current_value]).to(eq(15))
      end

      it "calculates a positive change since the previous snapshot" do
        expect(progression.technical_attributes[:att_fin][:change_since_previous]).to(eq(3))
      end

      it "calculates a negative change since the previous snapshot" do
        expect(progression.technical_attributes[:att_tck][:change_since_previous]).to(eq(-1))
      end

      it "calculates a positive change since the first snapshot" do
        expect(progression.technical_attributes[:att_fin][:change_since_first]).to(eq(5))
      end

      it "calculates a zero change since the first snapshot" do
        expect(progression.technical_attributes[:att_tck][:change_since_first]).to(eq(0))
      end
    end

    describe "#goalkeeper?" do
      it "returns false for an outfield player" do
        expect(progression.goalkeeper?).to(be(false))
      end

      it "returns true for a goalkeeper" do
        player.player_snapshots.last.update!(position_string: "GK")
        expect(progression.goalkeeper?).to(be(true))
      end
    end

    describe "#role_attributes" do
      let(:role1) { instance_double(Role, role_code: "st_af") }
      let(:role2) { instance_double(Role, role_code: "st_pf") }
      let(:role3) { instance_double(Role, role_code: "cm_bwm") }
      let(:all_roles) { [role1, role2, role3] }

      before do
        # Stub the RoleData service to avoid actual file I/O
        allow(RoleData).to(receive(:all_roles).and_return(all_roles))
      end

      it "returns all roles when no tactic is provided" do
        expect(progression.role_attributes).to(eq(all_roles))
      end

      it "returns only tactic-specific roles when a tactic is provided" do
        tactic_role = instance_double(TacticRole, role: "st_af")
        tactic = instance_double(Tactic, tactic_roles: [tactic_role])
        prog = described_class.new(player, tactic: tactic)

        # Allow pluck to be called on our double
        allow(tactic.tactic_roles).to(receive(:pluck).with(:role).and_return(["st_af"]))

        expect(prog.role_attributes).to(eq([role1]))
      end
    end

    describe "#role_ratings" do
      it "calculates and returns the player's role ratings" do
        mock_importer = instance_double(DataImporter)
        squad_data = [{ "name" => "Test Player" }]
        ratings = { "name" => "Test Player", "st_af" => 15.5 }

        # FIXED: Stub the call to #role_attributes to isolate this test
        allow(progression).to(receive(:role_attributes).and_return([]))

        # Stub the chain of calls to isolate our service
        allow(DataImporter).to(receive(:new).and_return(mock_importer))
        allow(mock_importer).to(receive_messages(process_database_snapshots: squad_data, calculate_role_ratings: [ratings]))

        expect(progression.role_ratings).to(eq(ratings))
      end
    end
  end

  context "with a player who has only one snapshot" do
    let(:progression) { described_class.new(player) }

    before do
      player.player_snapshots.create!(base_attributes.merge(snapshot_date: "2025-01-01", att_fin: 10))
    end

    it "calculates zero change since previous snapshot" do
      expect(progression.technical_attributes[:att_fin][:change_since_previous]).to(eq(0))
    end

    it "calculates zero change since first snapshot" do
      expect(progression.technical_attributes[:att_fin][:change_since_first]).to(eq(0))
    end
  end

  context "with a player who has no snapshots" do
    let(:progression) { described_class.new(player) }

    it "returns nil for the joined_date" do
      expect(progression.joined_date).to(be_nil)
    end

    it "returns zero for all attribute values and changes" do
      changes = progression.technical_attributes[:att_fin]
      expect(changes[:current_value]).to(eq(0))
      expect(changes[:change_since_previous]).to(eq(0))
      expect(changes[:change_since_first]).to(eq(0))
    end
  end
end
