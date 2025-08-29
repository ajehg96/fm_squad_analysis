# app/services/data_importer.rb

require "csv"
require "nokogiri"

class DataImporter
  # This is the list of attributes from your R script
  PLAYER_ATTRIBUTES = %w[att_cor att_cro att_dri att_fin att_fir att_fre att_hea att_lon att_lth att_mar att_pas att_pen att_tck att_tec att_agg att_ant att_bra att_cmp att_cnt att_dec att_det att_fla att_ldr att_otb att_pos att_tea att_vis att_wor att_acc att_agi att_bal att_jum att_nat att_pac att_sta att_str att_aer att_cmd att_com att_ecc att_han att_kic att_1v1 att_pun att_ref att_tro att_thr].freeze

  # ... (keep import_role_attributes, import_squad, process_role_attributes, process_squad_data)

  # PUBLIC METHODS
  # They are now simple and clear about their intent.

  def calculate_role_ratings(squad_data, role_attributes_data)
    # The standard calculation applies all penalties
    calculate_ratings(squad_data, role_attributes_data, penalize_youth: true)
  end

  def calculate_free_role_ratings(squad_data, role_attributes_data)
    # The "free" calculation does not apply positional penalties to youth
    calculate_ratings(squad_data, role_attributes_data, penalize_youth: false)
  end

  private

  # All the calculation logic now lives in one private method
  def calculate_ratings(squad_data, role_attributes_data, penalize_youth:)
    role_ratings = []

    squad_data.each do |player|
      player_ratings = { "name" => player["name"], "age" => player["age"], "potential" => player["potential"] }

      role_attributes_data.each do |role|
        sum_prod = 0
        sum_n = 0

        PLAYER_ATTRIBUTES.each do |attr|
          player_attr_value = player[attr].to_i
          role_attr_value = role[attr].to_i
          sum_prod += (player_attr_value * role_attr_value)
          sum_n += role_attr_value
        end

        score = sum_n.zero? ? 0 : sum_prod.to_f / sum_n

        # Determine if a positional penalty should be applied
        apply_penalty = penalize_youth || player["age"] > 21

        if apply_penalty
          if role["role_code"].start_with?("gk_") && !player["goal_keeper"]; score *= 0.2; end
          if role["role_code"].start_with?("cd_") && !player["central_defender"]; score *= 0.2; end
          # ... (include all the other 'if' statements for positional penalties here)
          if role["role_code"].start_with?("s_") && !player["striker"]; score *= 0.2; end
        end

        # Foot preference penalties always apply
        if (role["role_code"].end_with?("_r") || role["role_code"].end_with?("_li")) && player["foot_right"] && player["foot_right"] <= 4
          score = 0
        end
        if (role["role_code"].end_with?("_l") || role["role_code"].end_with?("_ri")) && player["foot_left"] && player["foot_left"] <= 4
          score = 0
        end

        player_ratings[role["role_code"]] = score
      end
      role_ratings << player_ratings
    end
    role_ratings
  end
end
