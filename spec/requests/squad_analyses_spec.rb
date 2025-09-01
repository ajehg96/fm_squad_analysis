# frozen_string_literal: true

require "rails_helper"

RSpec.describe("SquadAnalyses", type: :request) do
  describe "GET /new" do
    it "returns a successful response" do
      get new_squad_analysis_url
      expect(response).to(be_successful)
    end
  end

  describe "POST /create" do
    # FIX: Use the correct path relative to spec/fixtures/
    let(:file) { fixture_file_upload("squad.html", "text/html") }
    let(:snapshot_date) { Time.zone.today.to_s }
    let(:importer_double) { instance_double(DataImporter, import_squad: [], process_squad_data: []) }
    let(:persister_double) { instance_double(SquadDataPersister, persist: true) }

    before do
      # Make sure the fixture directory exists for the test
      FileUtils.mkdir_p(Rails.root.join("spec/fixtures/files"))
      FileUtils.touch(Rails.root.join("spec/fixtures/files/squad.html"))

      allow(DataImporter).to(receive(:new).and_return(importer_double))
      allow(SquadDataPersister).to(receive(:new).and_return(persister_double))
    end

    it "calls the importer and persister services" do
      post squad_analyses_url, params: { squad_file: file, snapshot_date: snapshot_date }
      expect(persister_double).to(have_received(:persist))
    end

    it "redirects to the show page" do
      post squad_analyses_url, params: { squad_file: file, snapshot_date: snapshot_date }
      expect(response).to(redirect_to(squad_analysis_url(:latest)))
    end
  end

  describe "GET /show" do
    let(:importer_double) { instance_double(DataImporter) }
    let(:assigner_double) { instance_double(TeamAssigner) }
    let(:fake_first_team) { [{ name: "Test Player", position: "GK", score: 15.0 }] }

    # FIX: Create a mock that responds to the methods the controller will call
    let(:fake_snapshots) { [instance_double(PlayerSnapshot, id: 1)] }
    let(:fake_relation) { PlayerSnapshot.where(id: fake_snapshots.map(&:id)) }

    before do
      # Mock the full database query chain
      allow(PlayerSnapshot).to(receive(:maximum).with(:snapshot_date).and_return(Time.zone.today))
      allow(PlayerSnapshot).to(receive(:where).and_return(fake_relation))
      allow(fake_relation).to(receive(:includes).with(:player).and_return(fake_snapshots))

      allow(DataImporter).to(receive(:new).and_return(importer_double))
      allow(importer_double).to(receive_messages(
        process_database_snapshots: [],
        import_role_attributes: [],
        process_role_attributes: [],
        calculate_role_ratings: [],
      ))

      allow(TeamAssigner).to(receive(:new).and_return(assigner_double))
      allow(assigner_double).to(receive_messages(
        assign_first_team: fake_first_team,
        assign_second_team: [],
        assign_third_team: [],
        assign_best_roles_for_remainder: [],
      ))
    end

    it "returns a successful response" do
      get squad_analysis_url(:latest)
      expect(response).to(be_successful)
    end

    it "renders the results in the response body" do
      get squad_analysis_url(:latest)
      expect(response.body).to(include("Test Player"))
      expect(response.body).to(include("GK"))
    end
  end
end
