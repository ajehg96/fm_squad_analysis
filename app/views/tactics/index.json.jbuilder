# frozen_string_literal: true

json.array!(@tactics, partial: "tactics/tactic", as: :tactic)
