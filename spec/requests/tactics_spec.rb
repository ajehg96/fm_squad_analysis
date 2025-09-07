# frozen_string_literal: true

require "rails_helper"

RSpec.describe("/tactics", type: :request) do
  # Define valid and invalid attributes for creating/updating tactics
  let(:valid_attributes) { { name: "New Tactic" } }
  let(:invalid_attributes) { { name: "" } }

  let!(:tactic) { Tactic.create!(valid_attributes) }

  describe "GET /index" do
    it "renders a successful response" do
      get tactics_url
      expect(response).to(be_successful)
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      get tactic_url(tactic)
      expect(response).to(be_successful)
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_tactic_url
      expect(response).to(be_successful)
    end
  end

  describe "GET /edit" do
    it "renders a successful response" do
      get edit_tactic_url(tactic)
      expect(response).to(be_successful)
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Tactic" do
        expect do
          post(tactics_url, params: { tactic: valid_attributes })
        end.to(change(Tactic, :count).by(1))
      end

      it "redirects to the created tactic" do
        post tactics_url, params: { tactic: valid_attributes }
        expect(response).to(redirect_to(tactic_url(Tactic.last)))
      end
    end

    context "with invalid parameters" do
      it "does not create a new Tactic" do
        expect do
          post(tactics_url, params: { tactic: invalid_attributes })
        end.not_to(change(Tactic, :count))
      end

      it "renders a response with 422 status" do
        post tactics_url, params: { tactic: invalid_attributes }
        # FIXED: Use :unprocessable_content instead of the deprecated :unprocessable_entity
        expect(response).to(have_http_status(:unprocessable_content))
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) { { name: "Updated Tactic Name" } }

      it "updates the requested tactic" do
        patch tactic_url(tactic), params: { tactic: new_attributes }
        tactic.reload
        expect(tactic.name).to(eq("Updated Tactic Name"))
      end

      it "redirects to the tactic" do
        patch tactic_url(tactic), params: { tactic: new_attributes }
        tactic.reload
        expect(response).to(redirect_to(tactic_url(tactic)))
      end
    end

    context "with invalid parameters" do
      it "renders a response with 422 status" do
        patch tactic_url(tactic), params: { tactic: invalid_attributes }
        # FIXED: Use :unprocessable_content instead of the deprecated :unprocessable_entity
        expect(response).to(have_http_status(:unprocessable_content))
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested tactic" do
      expect do
        delete(tactic_url(tactic))
      end.to(change(Tactic, :count).by(-1))
    end

    it "redirects to the tactics list" do
      delete tactic_url(tactic)
      expect(response).to(redirect_to(tactics_url))
    end
  end
end
