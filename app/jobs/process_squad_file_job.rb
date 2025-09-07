# frozen_string_literal: true

class ProcessSquadFileJob < ApplicationJob
  queue_as :default

  def perform(squad_file_path, snapshot_date)
    importer = DataImporter.new
    persister = SquadDataPersister.new

    raw_squad = importer.import_squad(squad_file_path)
    processed_data = importer.process_squad_data(raw_squad)
    persister.persist(processed_squad_data: processed_data, snapshot_date: snapshot_date)
  end
end
