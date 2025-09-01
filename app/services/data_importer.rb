# app/services/data_importer.rb
# frozen_string_literal: true

require "csv"
require "nokogiri"

# Service to import and process Football Manager data.
class DataImporter
  PLAYER_ATTRIBUTES = [
    "att_cor",
    "att_cro",
    "att_dri",
    "att_fin",
    "att_fir",
    "att_fre",
    "att_hea",
    "att_lon",
    "att_lth",
    "att_mar",
    "att_pas",
    "att_pen",
    "att_tck",
    "att_tec",
    "att_agg",
    "att_ant",
    "att_bra",
    "att_cmp",
    "att_cnt",
    "att_dec",
    "att_det",
    "att_fla",
    "att_ldr",
    "att_otb",
    "att_pos",
    "att_tea",
    "att_vis",
    "att_wor",
    "att_acc",
    "att_agi",
    "att_bal",
    "att_jum",
    "att_nat",
    "att_pac",
    "att_sta",
    "att_str",
    "att_aer",
    "att_cmd",
    "att_com",
    "att_ecc",
    "att_han",
    "att_kic",
    "att_1v1",
    "att_pun",
    "att_ref",
    "att_tro",
    "att_thr",
  ].freeze

  FOOT_STRENGTH_MAP = {
    "Very Weak" => 1,
    "Weak" => 2,
    "Reasonable" => 3,
    "Fairly Strong" => 4,
    "Strong" => 5,
    "Very Strong" => 6,
  }.freeze

  def process_database_snapshots(snapshots)
    snapshots.map do |snapshot|
      position_str = (snapshot.position_string || "").gsub(%r{/|,}, " ")
      snapshot.attributes.merge(
        "name" => snapshot.player.name,
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
      )
    end
  end

  def import_role_attributes(file_path)
    CSV.read(file_path, headers: true)
  end

  def import_squad(file_path)
    doc = Nokogiri::HTML(File.open(file_path), nil, "UTF-8")
    headers = doc.xpath("//th").map(&:text)
    rows = doc.xpath("//tr").map { |row| row.xpath("./td").map(&:text) }
    rows.reject!(&:empty?)
    rows.map { |row| Hash[headers.zip(row)] }
  end

  def process_role_attributes(raw_data)
    raw_data.map do |row|
      position_code = (row["position"] || "").split("_").map { |s| s[0] }.join
      role_code = (row["role"] || "").split("_").map { |s| s[0] }.join
      mentality_code = (row["mentality"] || "").split("_").map { |s| s[0] }.join
      side_code = (row["side"] || "").split("_").map { |s| s[0] }.join

      new_row = row.to_h.except("position", "role", "mentality", "side")
      new_row["role_code"] = "#{position_code}_#{role_code}_#{mentality_code}_#{side_code}"
      new_row
    end
  end

  def process_squad_data(raw_data)
    raw_data.filter_map do |row|
      next if row["Name"].nil? || row["Name"].strip.empty?

      map_player_data(row)
    end
  end

  def calculate_role_ratings(squad_data, role_attributes_data)
    calculate_ratings(squad_data, role_attributes_data, penalize_youth: true)
  end

  def calculate_free_role_ratings(squad_data, role_attributes_data)
    calculate_ratings(squad_data, role_attributes_data, penalize_youth: false)
  end

  private

  def map_player_data(row)
    position_str = (row["Position"] || "").gsub(%r{/|,}, " ")
    {
      "name" => row["Name"],
      "age" => row["Age"].to_i,
      "height" => row["Height"].to_i,
      "potential" => row["PA"].to_i,
      "position_string" => row["Position"],
      "foot_right" => FOOT_STRENGTH_MAP[row["Right Foot"]] || 0,
      "foot_left" => FOOT_STRENGTH_MAP[row["Left Foot"]] || 0,
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
    }.merge(map_player_attributes(row))
  end

  def map_player_attributes(row)
    {
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
  end

  def calculate_ratings(squad_data, role_attributes_data, penalize_youth:)
    squad_data.map do |player|
      player_ratings = { "name" => player["name"], "age" => player["age"], "potential" => player["potential"] }
      role_attributes_data.each do |role|
        player_ratings[role["role_code"]] = calculate_single_score(player, role, penalize_youth)
      end
      player_ratings
    end
  end

  def calculate_single_score(player, role, penalize_youth)
    sum_prod = 0
    sum_n = 0

    PLAYER_ATTRIBUTES.each do |attr|
      sum_prod += player[attr].to_i * role[attr].to_i
      sum_n += role[attr].to_i
    end

    score = sum_n.zero? ? 0 : sum_prod.to_f / sum_n
    apply_penalties(score, player, role["role_code"], penalize_youth)
  end

  def apply_penalties(score, player, role_code, penalize_youth)
    # 1. Apply positional penalty
    apply_pos_penalty = penalize_youth || player["age"] > 21
    if apply_pos_penalty
      position_prefix = role_code.split("_").first
      is_unnatural = case position_prefix
      when "gk" then !player["goal_keeper"]
      when "cd" then !player["central_defender"]
      when "fb" then !player["full_back"]
      when "dm" then !player["defensive_midfielder"]
      when "wb" then !player["wing_back"]
      when "cm" then !player["central_midfielder"]
      when "wm" then !player["wide_midfielder"]
      when "am" then !player["attacking_midfielder"]
      when "w" then !player["winger"]
      when "s" then !player["striker"]
      else false
      end
      score *= 0.2 if is_unnatural
    end

    # 2. Apply footedness penalty (this was the missing logic)
    if role_code.end_with?("_r", "_li") && player["foot_right"] <= 4
      return 0
    end
    if role_code.end_with?("_l", "_ri") && player["foot_left"] <= 4
      return 0
    end

    score
  end
end
