# frozen_string_literal: true

require "rails_helper"

RSpec.describe("Players", type: "request") do
  describe "GET /show" do
    let!(:player) { Player.create!(name: "Test Player") }

    before do
      player.player_snapshots.create!(snapshot_date: Time.zone.today)
    end

    it "returns http success" do
      get player_url(player)
      expect(response).to(have_http_status(:success))
    end
  end
end
