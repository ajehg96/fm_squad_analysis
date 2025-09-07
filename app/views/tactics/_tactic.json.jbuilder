# frozen_string_literal: true

json.extract!(tactic, :id, :name, :description, :created_at, :updated_at)
json.url(tactic_url(tactic, format: :json))
