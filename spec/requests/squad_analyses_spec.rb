# frozen_string_literal: true

require "rails_helper"

RSpec.describe("/squad_analyses", type: :request) do
  describe "GET /new" do
    it "renders a successful response" do
      get new_squad_analysis_url
      expect(response).to(be_successful)
    end
  end

  describe "GET /show" do
    let!(:tactic) { Tactic.create!(name: "Test Tactic") }

    it "returns a successful response" do
      get squad_analysis_url(:latest)
      expect(response).to(be_successful)
    end

    it "renders the results in the response body" do
      get squad_analysis_url(:latest)
      expect(response.body).to(include("Squad Analysis Results"))
    end
  end

  describe "POST /create" do
    it "redirects to the show page" do
      # FIXED: Simplified the path to look directly in 'spec/fixtures/'.
      dummy_file = fixture_file_upload("dummy.html", "text/html")

      # We mock the service to prevent the test from actually processing the file,
      # as we're only testing that the controller redirects correctly.
      allow_any_instance_of(SquadDataPersister).to(receive(:persist).and_return(true))

      post squad_analyses_url, params: { squad_file: dummy_file, snapshot_date: "2025-01-01" }
      expect(response).to(redirect_to(squad_analysis_url(:latest)))
    end
  end
end
