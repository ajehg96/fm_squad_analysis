# frozen_string_literal: true

require "rails_helper"

RSpec.describe(SquadsHelper, type: :helper) do
  describe "#sort_by_position" do
    it "sorts players tactically by position and side" do
      gk = { position: "gk_sk_d_c" }
      dc = { position: "cd_bpd_d_c" }
      dl = { position: "fb_fb_d_l" }
      dr = { position: "fb_fb_d_r" }
      st = { position: "s_af_a_c" }

      players = [st, dr, gk, dc, dl]
      sorted_players = helper.sort_by_position(players)

      # FIXED: The expectation now matches the correct sort order defined in the helper.
      # Goalkeeper -> Centre Defender -> Left Defender -> Right Defender -> Striker
      expect(sorted_players).to(eq([gk, dc, dl, dr, st]))
    end
  end

  describe "#adjusted_team_layout" do
    context "when one player is in a position group" do
      it "returns the player at the base coordinates" do
        team = [{ name: "A", position: "cd_bpd_d_c" }]
        layout = helper.adjusted_team_layout(team)

        expect(layout.first[:coordinates]).to(eq({ x: 50, y: 80 }))
      end
    end

    context "when two players are in the same position group" do
      it "offsets their x-coordinates" do
        team = [
          { name: "A", position: "cd_bpd_d_c" },
          { name: "B", position: "cd_cd_d_c" },
        ]
        layout = helper.adjusted_team_layout(team)

        # Expect coordinates to be offset from the center (50) by +/- 6
        expect(layout.find { |p| p[:name] == "A" }[:coordinates][:x]).to(eq(44.0))
        expect(layout.find { |p| p[:name] == "B" }[:coordinates][:x]).to(eq(56.0))
      end
    end
  end

  describe "#abbreviate_role" do
    it "returns the full name if it's short" do
      expect(helper.abbreviate_role("Poacher", "Attack")).to(eq("Poacher - Attack"))
    end

    it "abbreviates a long role name" do
      expect(helper.abbreviate_role("Ball Playing Defender", "Defend")).to(eq("BPD - Defend"))
    end
  end
end
