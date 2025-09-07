# frozen_string_literal: true

require "rails_helper"

RSpec.describe(TacticsController, type: :routing) do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/tactics").to(route_to("tactics#index"))
    end

    it "routes to #new" do
      expect(get: "/tactics/new").to(route_to("tactics#new"))
    end

    it "routes to #show" do
      expect(get: "/tactics/1").to(route_to("tactics#show", id: "1"))
    end

    it "routes to #edit" do
      expect(get: "/tactics/1/edit").to(route_to("tactics#edit", id: "1"))
    end

    it "routes to #create" do
      expect(post: "/tactics").to(route_to("tactics#create"))
    end

    it "routes to #update via PUT" do
      expect(put: "/tactics/1").to(route_to("tactics#update", id: "1"))
    end

    it "routes to #update via PATCH" do
      expect(patch: "/tactics/1").to(route_to("tactics#update", id: "1"))
    end

    it "routes to #destroy" do
      expect(delete: "/tactics/1").to(route_to("tactics#destroy", id: "1"))
    end
  end
end
