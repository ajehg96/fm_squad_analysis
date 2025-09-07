# frozen_string_literal: true

require "rails_helper"
require_relative "../../app/services/role_data"

RSpec.describe(RoleData) do
  # Before each test, reset the memoized variable to ensure a clean state
  before do
    described_class.instance_variable_set(:@all_roles, nil)
  end

  describe ".all_roles" do
    let(:mock_importer) { instance_double(DataImporter) }
    let(:raw_attributes) { "some raw csv data" }
    let(:processed_roles) { [instance_double(Role, role_code: "st_af")] }

    before do
      # Mock the entire chain of dependencies
      allow(DataImporter).to(receive(:new).and_return(mock_importer))
      allow(mock_importer).to(receive(:import_role_attributes).and_return(raw_attributes))
      allow(mock_importer).to(receive(:process_role_attributes).with(raw_attributes).and_return(processed_roles))
    end

    context "when the data file exists" do
      it "loads and processes role attributes from the CSV" do
        roles = described_class.all_roles
        expect(roles).to(eq(processed_roles))
      end

      it "memoizes the result and does not re-process the file on subsequent calls" do
        # Expect the importer to be created and used only once
        expect(DataImporter).to(receive(:new).once.and_return(mock_importer))

        # Call the method twice
        described_class.all_roles
        roles = described_class.all_roles

        # The result should still be correct
        expect(roles).to(eq(processed_roles))
      end
    end

    context "when the data file does not exist" do
      it "raises an error" do
        # Simulate a "File Not Found" error
        allow(mock_importer).to(receive(:import_role_attributes).and_raise(Errno::ENOENT))

        # Expect the code to raise the same error, which is a reasonable default behaviour
        expect { described_class.all_roles }.to(raise_error(Errno::ENOENT))
      end
    end
  end
end
