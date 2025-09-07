# frozen_string_literal: true

require "rails_helper"

RSpec.describe("tactics/edit", type: :view) do
  let(:tactic) do
    Tactic.create!(
      name: "MyString",
      description: "MyText",
    )
  end

  before do
    assign(:tactic, tactic)
  end

  it "renders the edit tactic form" do
    render

    assert_select "form[action=?][method=?]", tactic_path(tactic), "post" do
      assert_select "input[name=?]", "tactic[name]"

      assert_select "textarea[name=?]", "tactic[description]"
    end
  end
end
