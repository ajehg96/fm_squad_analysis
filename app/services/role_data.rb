# frozen_string_literal: true

# This service loads and caches the role attribute data from the CSV file
# to prevent reading and processing the file multiple times.
module RoleData
  def self.all_roles
    # The ||= operator ensures this block only runs once, caching the result.
    @all_roles ||= begin
      importer = DataImporter.new
      file_path = Rails.root.join("data/role_attributes.csv")
      raw_attributes = importer.import_role_attributes(file_path)
      importer.process_role_attributes(raw_attributes)
    end
  end
end
