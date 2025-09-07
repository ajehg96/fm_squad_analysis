# frozen_string_literal: true

require "rails_helper"

RSpec.describe(TacticsHelper, type: :helper) do
  describe "#role_options" do
    it "returns a sorted list of all roles" do
      # Create mock Role objects to use as test data
      role_c = OpenStruct.new(position: "ST", role: "Poacher", mentality: "Attack")
      role_a = OpenStruct.new(position: "GK", role: "Goalkeeper", mentality: "Defend")
      role_b = OpenStruct.new(position: "MC", role: "Mezzala", mentality: "Support")

      # Stub the RoleData service to return our predictable mock data
      allow(RoleData).to(receive(:all_roles).and_return([role_c, role_a, role_b]))

      # The helper should sort the roles by position
      expected_order = [role_a, role_b, role_c]

      expect(helper.role_options).to(eq(expected_order))
    end
  end
end
