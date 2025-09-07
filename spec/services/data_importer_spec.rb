# frozen_string_literal: true

require_relative "../spec_helper"
require_relative "../../app/services/data_importer"

RSpec.describe(DataImporter) do
  let(:importer) { described_class.new }

  describe "#import_squad" do
    context "with a valid HTML file" do
      let(:html_content) do
        <<~HTML
          <table>
            <tr><th>Name</th><th>Age</th><th>Position</th></tr>
            <tr><td>Player One</td><td> 21 </td><td> ST (C) </td></tr>
            <tr><td>Player Two</td><td>25</td><td>D (RLC)</td></tr>
          </table>
        HTML
      end
      let(:file) { StringIO.new(html_content) }

      before do
        allow(File).to(receive(:open).and_return(file))
      end

      it "returns the correct number of players" do
        expect(importer.import_squad("dummy_path.html").size).to(eq(2))
      end

      it "parses player data into a hash with stripped values" do
        player_data = importer.import_squad("dummy_path.html").first
        expected_data = {
          "Name" => "Player One",
          "Age" => "21",
          "Position" => "ST (C)",
        }
        expect(player_data).to(eq(expected_data))
      end
    end

    context "with a malformed row" do
      let(:html_content) do
        <<~HTML
          <table>
            <tr><th>Name</th><th>Age</th></tr>
            <tr><td>Player One</td></tr>
          </table>
        HTML
      end
      let(:file) { StringIO.new(html_content) }

      it "assigns nil to missing values" do
        allow(File).to(receive(:open).and_return(file))
        player_data = importer.import_squad("dummy_path.html").first
        expect(player_data["Name"]).to(eq("Player One"))
        expect(player_data["Age"]).to(be_nil)
      end
    end

    context "with no table in the file" do
      let(:file) { StringIO.new("<div>No table here</div>") }

      it "returns an empty array" do
        allow(File).to(receive(:open).and_return(file))
        expect(importer.import_squad("dummy_path.html")).to(be_empty)
      end
    end
  end

  describe "#process_squad_data" do
    let(:raw_data) do
      [
        { "Name" => "Valid Player", "Age" => "22", "Position" => "ST", "Right Foot" => "Strong" },
        { "Name" => nil, "Age" => "20" },
        { "Name" => "  ", "Age" => "21" },
      ]
    end

    it "filters out players with nil or blank names" do
      processed = importer.process_squad_data(raw_data)
      expect(processed.size).to(eq(1))
      expect(processed.first["name"]).to(eq("Valid Player"))
    end

    it "maps the raw data to the correct types and structure" do
      processed = importer.process_squad_data(raw_data).first
      expect(processed["age"]).to(be_a(Integer))
      expect(processed["age"]).to(eq(22))
      expect(processed["striker"]).to(be(true))
      expect(processed["foot_right"]).to(eq(5))
    end
  end

  describe "#import_role_attributes & #process_role_attributes" do
    let(:csv_content) { "role_code,att_tck,att_mar\ncd_bpd,5,5\nst_af,1,2" }
    let(:file) { StringIO.new(csv_content) }

    it "correctly parses CSV and maps to Role objects" do
      mock_role_class = Struct.new(:role_code, :att_tck, :att_mar, keyword_init: true) do
        def initialize(attributes = {})
          super(attributes.transform_keys(&:to_sym))
        end
      end
      stub_const("Role", mock_role_class)

      allow(CSV).to(receive(:read).and_return(CSV.parse(file, headers: true)))

      raw_roles = importer.import_role_attributes("dummy.csv")
      roles = importer.process_role_attributes(raw_roles)

      expect(roles.size).to(eq(2))
      expect(roles.first).to(be_a(mock_role_class))
      expect(roles.first.role_code).to(eq("cd_bpd"))
      expect(roles.first.att_tck.to_i).to(eq(5))
    end
  end

  describe "#calculate_role_ratings" do
    let(:role_attributes) do
      [
        { "role_code" => "gkskdc_sk_d_c", "att_cor" => 10, "att_cro" => 5 },
        { "role_code" => "cdbpdc_bpd_d_c", "att_cor" => 5, "att_cro" => 10 },
        { "role_code" => "fb_iwb_s_r", "att_cor" => 10, "att_cro" => 0 },
        { "role_code" => "w_iw_a_l", "att_cor" => 10, "att_cro" => 0 },
        { "role_code" => "zero_weight_role", "att_cor" => 0, "att_cro" => 0 },
      ]
    end

    let(:squad_data) do
      [
        { "name" => "Player A", "age" => 25, "goal_keeper" => true, "att_cor" => 15, "att_cro" => 10, "foot_right" => 6, "foot_left" => 6 },
        { "name" => "Player B", "age" => 25, "central_defender" => true, "att_cor" => 10, "att_cro" => 15, "foot_right" => 6, "foot_left" => 6 },
        { "name" => "Older Oop", "age" => 25, "goal_keeper" => false, "att_cor" => 10, "att_cro" => 10, "foot_right" => 6, "foot_left" => 6 },
        { "name" => "Younger Oop", "age" => 20, "goal_keeper" => false, "att_cor" => 10, "att_cro" => 10, "foot_right" => 6, "foot_left" => 6 },
        { "name" => "Weak Right", "age" => 25, "full_back" => true, "att_cor" => 15, "foot_right" => 3, "foot_left" => 6 },
        { "name" => "Weak Left", "age" => 25, "winger" => true, "att_cor" => 15, "foot_right" => 6, "foot_left" => 3 },
      ]
    end

    let(:role_ratings) { importer.calculate_role_ratings(squad_data, role_attributes) }

    it "calculates ratings correctly for Player A in natural position" do
      player_a_rating = role_ratings.find { |p| p["name"] == "Player A" }["gkskdc_sk_d_c"]
      expect(player_a_rating).to(be_within(0.01).of(13.33))
    end

    context "when a player is out of position" do
      it "penalizes an older player" do
        rating = role_ratings.find { |p| p["name"] == "Older Oop" }["gkskdc_sk_d_c"]
        expect(rating).to(be_within(0.01).of(2.0))
      end

      it "also penalizes a younger player (because penalize_youth is true)" do
        rating = role_ratings.find { |p| p["name"] == "Younger Oop" }["gkskdc_sk_d_c"]
        expect(rating).to(be_within(0.01).of(2.0))
      end
    end

    context "with footedness penalties" do
      it "gives a score of 0 to a player with a weak right foot in a right-sided role" do
        rating = role_ratings.find { |p| p["name"] == "Weak Right" }["fb_iwb_s_r"]
        expect(rating).to(eq(0))
      end

      it "gives a score of 0 to a player with a weak left foot in a left-sided role" do
        rating = role_ratings.find { |p| p["name"] == "Weak Left" }["w_iw_a_l"]
        expect(rating).to(eq(0))
      end
    end

    context "with a zero-weight role" do
      it "returns a score of 0 and does not divide by zero" do
        rating = role_ratings.find { |p| p["name"] == "Player A" }["zero_weight_role"]
        expect(rating).to(eq(0))
      end
    end
  end

  describe "#calculate_free_role_ratings" do
    let(:role_attributes) do
      [{ "role_code" => "cd_bpd_d_c", "att_tck" => 5, "att_mar" => 5 }]
    end

    let(:squad_data) do
      [
        { "name" => "Young Striker", "age" => 20, "central_defender" => false, "att_tck" => 5, "att_mar" => 5 },
        { "name" => "Senior Striker", "age" => 28, "central_defender" => false, "att_tck" => 5, "att_mar" => 5 },
      ]
    end

    let(:free_ratings) { importer.calculate_free_role_ratings(squad_data, role_attributes) }

    it "does NOT penalize a young player in an unnatural position" do
      young_striker_rating = free_ratings.find { |p| p["name"] == "Young Striker" }["cd_bpd_d_c"]
      expect(young_striker_rating).to(be_within(0.01).of(5.0))
    end

    it "STILL penalizes an older player in an unnatural position" do
      senior_striker_rating = free_ratings.find { |p| p["name"] == "Senior Striker" }["cd_bpd_d_c"]
      expect(senior_striker_rating).to(be_within(0.01).of(1.0))
    end
  end
end
