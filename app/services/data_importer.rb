# frozen_string_literal: true

# app/services/data_importer.rb

require "csv"
require "nokogiri"

class DataImporter
  PLAYER_ATTRIBUTES = ["att_cor", "att_cro", "att_dri", "att_fin", "att_fir", "att_fre", "att_hea", "att_lon", "att_lth", "att_mar", "att_pas", "att_pen", "att_tck", "att_tec", "att_agg", "att_ant", "att_bra", "att_cmp", "att_cnt", "att_dec", "att_det", "att_fla", "att_ldr", "att_otb", "att_pos", "att_tea", "att_vis", "att_wor", "att_acc", "att_agi", "att_bal", "att_jum", "att_nat", "att_pac", "att_sta", "att_str", "att_aer", "att_cmd", "att_com", "att_ecc", "att_han", "att_kic", "att_1v1", "att_pun", "att_ref", "att_tro", "att_thr"].freeze

  def import_role_attributes(file_path)
    CSV.read(file_path, headers: true)
  end

  def import_squad(file_path)
    doc = Nokogiri::HTML(File.open(file_path), nil, "UTF-8")
    headers = doc.xpath("//th").map(&:text)
    rows = doc.xpath("//tr").map do |row| # Process all <tr> tags
      row.xpath("./td").map(&:text)
    end

    # Filter out empty rows (like the header which has no <td>s)
    rows.reject!(&:empty?)

    rows.map { |row| Hash[headers.zip(row)] }
  end

  def process_role_attributes(raw_data)
    processed_data = []
    raw_data.each do |row|
      position_code = (row["position"] || "").split("_").map { |s| s[0] }.join
      role_code = (row["role"] || "").split("_").map { |s| s[0] }.join
      mentality_code = (row["mentality"] || "").split("_").map { |s| s[0] }.join
      side_code = (row["side"] || "").split("_").map { |s| s[0] }.join

      new_row = row.to_h.except("position", "role", "mentality", "side")
      new_row["role_code"] = "#{position_code}_#{role_code}_#{mentality_code}_#{side_code}"
      processed_data << new_row
    end
    processed_data
  end

  def process_squad_data(raw_data)
    foot_strength_map = {
      "Very Weak" => 1,
      "Weak" => 2,
      "Reasonable" => 3,
      "Fairly Strong" => 4,
      "Strong" => 5,
      "Very Strong" => 6,
    }

    processed_rows = []
    raw_data.each do |row|
      # --- ROBUSTNESS CHECK ---
      # Skip any row that doesn't have a name. This filters out bad data.
      next if row["Name"].nil? || row["Name"].strip.empty?

      position_str = (row["Position"] || "").gsub(%r{/|,}, " ")

      player_data = {
        "name" => row["Name"],
        "age" => row["Age"].to_i,
        "height" => row["Height"].to_i,
        "potential" => row["PA"].to_i,
        "foot_right" => foot_strength_map[row["Right Foot"]] || 0,
        "foot_left" => foot_strength_map[row["Left Foot"]] || 0,
        "goal_keeper" => position_str.include?("GK"),
        "full_back" => position_str.match?(/\b(D|WB)\s*\((\w*[RL]\w*)\)/),
        "central_defender" => position_str.match?(/\bD\s*\((\w*C\w*)\)/),
        "wing_back" => position_str.include?("WB"),
        "defensive_midfielder" => position_str.include?("DM"),
        "wide_midfielder" => position_str.match?(/\bM\s*\((\w*[RL]\w*)\)/),
        "central_midfielder" => position_str.match?(/\bM\s*\((\w*C\w*)\)/),
        "winger" => position_str.match?(/\bAM\s*\((\w*[RL]\w*)\)/),
        "attacking_midfielder" => position_str.match?(/\bAM\s*\((\w*C\w*)\)/),
        "striker" => position_str.include?("ST"),
        "att_cor" => row["Cor"].to_i,
        "att_cro" => row["Cro"].to_i,
        "att_dri" => row["Dri"].to_i,
        "att_fin" => row["Fin"].to_i,
        "att_fir" => row["Fir"].to_i,
        "att_fre" => row["Fre"].to_i,
        "att_hea" => row["Hea"].to_i,
        "att_lon" => row["Lon"].to_i,
        "att_lth" => row["L Th"].to_i,
        "att_mar" => row["Mar"].to_i,
        "att_pas" => row["Pas"].to_i,
        "att_pen" => row["Pen"].to_i,
        "att_tck" => row["Tck"].to_i,
        "att_tec" => row["Tec"].to_i,
        "att_agg" => row["Agg"].to_i,
        "att_ant" => row["Ant"].to_i,
        "att_bra" => row["Bra"].to_i,
        "att_cmp" => row["Cmp"].to_i,
        "att_cnt" => row["Cnt"].to_i,
        "att_dec" => row["Dec"].to_i,
        "att_det" => row["Det"].to_i,
        "att_fla" => row["Fla"].to_i,
        "att_ldr" => row["Ldr"].to_i,
        "att_otb" => row["OtB"].to_i,
        "att_pos" => row["Pos"].to_i,
        "att_tea" => row["Tea"].to_i,
        "att_vis" => row["Vis"].to_i,
        "att_wor" => row["Wor"].to_i,
        "att_acc" => row["Acc"].to_i,
        "att_agi" => row["Agi"].to_i,
        "att_bal" => row["Bal"].to_i,
        "att_jum" => row["Jum"].to_i,
        "att_nat" => row["Nat"].to_i,
        "att_pac" => row["Pac"].to_i,
        "att_sta" => row["Sta"].to_i,
        "att_str" => row["Str"].to_i,
        "att_aer" => row["Aer"].to_i,
        "att_cmd" => row["Cmd"].to_i,
        "att_com" => row["Com"].to_i,
        "att_ecc" => row["Ecc"].to_i,
        "att_han" => row["Han"].to_i,
        "att_kic" => row["Kic"].to_i,
        "att_1v1" => row["1v1"].to_i,
        "att_pun" => row["Pun"].to_i,
        "att_ref" => row["Ref"].to_i,
        "att_tro" => row["TRO"].to_i,
        "att_thr" => row["Thr"].to_i,
      }
      processed_rows << player_data
    end
    processed_rows
  end

  def calculate_role_ratings(squad_data, role_attributes_data)
    calculate_ratings(squad_data, role_attributes_data, penalize_youth: true)
  end

  def calculate_free_role_ratings(squad_data, role_attributes_data)
    calculate_ratings(squad_data, role_attributes_data, penalize_youth: false)
  end

  private

  def calculate_ratings(squad_data, role_attributes_data, penalize_youth:)
    squad_data.map do |player|
      player_ratings = { "name" => player["name"], "age" => player["age"], "potential" => player["potential"] }

      role_attributes_data.each do |role|
        role_code = role["role_code"]
        sum_prod = 0
        sum_n = 0

        PLAYER_ATTRIBUTES.each do |attr|
          player_attr_value = player[attr].to_i
          role_attr_value = role[attr].to_i
          sum_prod += (player_attr_value * role_attr_value)
          sum_n += role_attr_value
        end

        score = sum_n.zero? ? 0 : sum_prod.to_f / sum_n

        apply_penalty = penalize_youth || player["age"] > 21

        if apply_penalty
          role_code.start_with?("gk_") && !player["goal_keeper"] ? score *= 0.2 : nil
          role_code.start_with?("cd_") && !player["central_defender"] ? score *= 0.2 : nil
          role_code.start_with?("fb_") && !player["full_back"] ? score *= 0.2 : nil
          role_code.start_with?("dm_") && !player["defensive_midfielder"] ? score *= 0.2 : nil
          role_code.start_with?("wb_") && !player["wing_back"] ? score *= 0.2 : nil
          role_code.start_with?("cm_") && !player["central_midfielder"] ? score *= 0.2 : nil
          role_code.start_with?("wm_") && !player["wide_midfielder"] ? score *= 0.2 : nil
          role_code.start_with?("am_") && !player["attacking_midfielder"] ? score *= 0.2 : nil
          role_code.start_with?("w_") && !player["winger"] ? score *= 0.2 : nil
          role_code.start_with?("s_") && !player["striker"] ? score *= 0.2 : nil
        end

        role_code.end_with?("_r", "_li") && player["foot_right"] <= 4 ? score = 0 : nil
        role_code.end_with?("_l", "_ri") && player["foot_left"] <= 4 ? score = 0 : nil

        player_ratings[role_code] = score
      end
      player_ratings
    end
  end
end
