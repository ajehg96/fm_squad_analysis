# frozen_string_literal: true

require "rails_helper"

RSpec.describe("tactics/new", type: :view) do
  before do
    assign(:tactic, Tactic.new(
      name: "MyString",
      description: "MyText",
    ))
  end

  it "renders new tactic form" do
    render

    assert_select "form[action=?][method=?]", tactics_path, "post" do
      assert_select "input[name=?]", "tactic[name]"

      assert_select "textarea[name=?]", "tactic[description]"
    end
  end
end
