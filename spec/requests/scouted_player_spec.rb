# frozen_string_literal: true

require "rails_helper"

RSpec.describe("/scouted_players", type: :request) do
  # The index page needs at least one tactic to exist.
  let!(:tactic) do
    Tactic.create!(name: "Test Tactic").tap do |t|
      # It also needs at least one role, and the role name must be a valid
      # role_code from your roles CSV file.
      t.tactic_roles.create!(role: "cdbpdc_bpd_d_c")
    end
  end

  # The index page needs at least one scouted player with a snapshot to display.
  let!(:scouted_player) do
    Player.create!(name: "Scouted Test Player", scouted: true).tap do |p|
      p.player_snapshots.create!(
        DataImporter::PLAYER_ATTRIBUTES.index_with { 10 }.merge(
          snapshot_date: Date.today,
          foot_right: 6,
          foot_left: 6,
        ),
      )
    end
  end

  # Create a mock Role object that matches the TacticRole we created above.
  let(:role_double) do
    # We use an OpenStruct here for simplicity as a stand-in for your Role class
    OpenStruct.new(role_code: "cdbpdc_bpd_d_c", role: "Ball Playing Defender", side: "Centre")
  end

  before do
    # FIXED: Stub the RoleData service to return our predictable mock role.
    # This prevents the test from reading the external CSV file.
    allow(RoleData).to(receive(:all_roles).and_return([role_double]))
  end

  describe "GET /index" do
    it "renders a successful response" do
      get scouted_players_url
      expect(response).to(be_successful)
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_scouted_player_url
      expect(response).to(be_successful)
    end
  end

  describe "POST /create" do
    it "redirects to the index page after a file upload" do
      dummy_file = fixture_file_upload("dummy.html", "text/html")

      persister_double = instance_double(ScoutedDataPersister)
      allow(ScoutedDataPersister).to(receive(:new).and_return(persister_double))
      allow(persister_double).to(receive(:persist))

      post scouted_players_url, params: { scouted_file: dummy_file }

      expect(response).to(redirect_to(scouted_players_url))
      expect(flash[:notice]).to(eq("Scouted players file was successfully uploaded."))
    end
  end
end
