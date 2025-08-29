# frozen_string_literal: true

class SquadsController < ApplicationController
  def show
    importer = DataImporter.new

    squad_file = Rails.root.join("data/squad.html")
    attributes_file = Rails.root.join("data/role_attributes.csv")

    raw_squad = importer.import_squad(squad_file)
    squad_data = importer.process_squad_data(raw_squad)

    raw_attributes = importer.import_role_attributes(attributes_file)
    role_attributes = importer.process_role_attributes(raw_attributes)

    role_ratings = importer.calculate_role_ratings(squad_data, role_attributes)

    tactic = [
      { "position" => "gk_sk_d_c", "number" => 1 },
      { "position" => "cd_bpd_d_c", "number" => 2 },
      { "position" => "wb_wb_a_r", "number" => 1 },
      { "position" => "dm_sv_a_c", "number" => 1 },
      { "position" => "wb_wb_a_l", "number" => 1 },
      { "position" => "w_if_a_ri", "number" => 1 },
      { "position" => "w_if_a_li", "number" => 1 },
      { "position" => "s_af_a_c", "number" => 1 },
    ]

    assigner = TeamAssigner.new

    @first_team = assigner.assign_first_team(role_ratings, tactic)
    @second_team = assigner.assign_second_team(role_ratings, tactic, @first_team)
    @third_team = assigner.assign_third_team(role_ratings, tactic, @first_team, @second_team)
    @remainder = assigner.assign_best_roles_for_remainder(role_ratings, @first_team, @second_team, @third_team)
  end
end
