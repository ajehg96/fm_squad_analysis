# frozen_string_literal: true

require "rails_helper"

RSpec.describe(SquadAnalysisReport) do
  let!(:tactic) { Tactic.create!(name: "Test Tactic") }

  context "when no player snapshots exist" do
    it "initializes with a nil snapshot_date and empty teams" do
      report = described_class.new(tactic: tactic)

      expect(report.snapshot_date).to(be_nil)
      expect(report.first_team).to(be_nil)
    end
  end

  context "when only one snapshot date exists" do
    let!(:player) do
      Player.create!(name: "Test Player", scouted: false).tap do |p|
        p.player_snapshots.create!(
          DataImporter::PLAYER_ATTRIBUTES.index_with { 10 }.merge(
            snapshot_date: "2025-01-01",
            foot_right: 6,
            foot_left: 6,
            age: 20,
            potential: 150,
            position_string: "ST (C)", # Add position string
          ),
        )
      end
    end

    it "does not calculate rating differences" do
      allow_any_instance_of(TeamAssigner).to(receive(:assign_first_team).and_return(
        [{ name: "Test Player", position: "s_af_a_c", score: 10 }],
      ))

      report = described_class.new(tactic: tactic)

      expect(report.first_team.first[:rating_diff]).to(be_nil)
    end
  end

  context "when two snapshot dates exist" do
    let!(:player) do
      Player.create!(name: "Test Player", scouted: false).tap do |p|
        # FIXED: Add a position_string to both snapshots.
        p.player_snapshots.create!(
          DataImporter::PLAYER_ATTRIBUTES.index_with { 10 }.merge(
            snapshot_date: "2025-01-01",
            foot_right: 6,
            foot_left: 6,
            age: 20,
            potential: 150,
            position_string: "ST (C)",
          ),
        )
        p.player_snapshots.create!(
          DataImporter::PLAYER_ATTRIBUTES.index_with { 12 }.merge(
            snapshot_date: "2025-02-01",
            foot_right: 6,
            foot_left: 6,
            age: 21,
            potential: 150,
            position_string: "ST (C)",
          ),
        )
      end
    end

    it "calculates the correct rating difference" do
      allow_any_instance_of(TeamAssigner).to(receive(:assign_first_team).and_return(
        [{ name: "Test Player", position: "s_af_a_c", score: 12.0 }],
      ))

      report = described_class.new(tactic: tactic)

      expect(report.first_team.first[:rating_diff]).to(be_within(0.01).of(2.0))
    end
  end
end
