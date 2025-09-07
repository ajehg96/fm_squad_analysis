# frozen_string_literal: true

require "rails_helper"

RSpec.describe("Players", type: :request) do
  describe "GET /show" do
    # FIXED: We need to create a player that has a complete snapshot,
    # otherwise the ratings calculation in the view will fail.
    let!(:player) do
      Player.create!(name: "Test Player").tap do |p|
        p.player_snapshots.create!(
          DataImporter::PLAYER_ATTRIBUTES.index_with { 10 }.merge(
            snapshot_date: Time.zone.today,
            foot_right: 6,
            foot_left: 6,
          ),
        )
      end
    end

    it "returns http success" do
      get player_url(player)
      expect(response).to(have_http_status(:success))
    end
  end
end
