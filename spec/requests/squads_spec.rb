# frozen_string_literal: true

require "rails_helper"

# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe("Squads", type: :request) do
  describe "GET /show" do
    let(:importer_double) { instance_double(DataImporter) }
    let(:assigner_double) { instance_double(TeamAssigner) }

    let(:fake_squad_data) { [{ name: "Fake Player" }] }
    let(:fake_attributes) { [{ role_code: "fake_role" }] }
    let(:fake_ratings) { [{ name: "Fake Player", fake_role: 10.0 }] }
    let(:fake_first_team) { [{ name: "First Team Player", position: "GK", score: 15.0 }] }

    before do
      allow(DataImporter).to(receive(:new).and_return(importer_double))
      allow(importer_double).to(receive_messages(
        import_squad: [],
        process_squad_data: fake_squad_data,
        import_role_attributes: [],
        process_role_attributes: fake_attributes,
        calculate_role_ratings: fake_ratings,
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
      get squads_show_url
      expect(response).to(be_successful)
    end

    it "renders the first team players in the response body" do
      get squads_show_url

      expect(response.body).to(include("First Team Player"))
    end

    it "renders the goalkeeper in the response body" do
      get squads_show_url

      expect(response.body).to(include("GK"))
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
