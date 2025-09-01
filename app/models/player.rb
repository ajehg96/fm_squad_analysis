# frozen_string_literal: true

class Player < ApplicationRecord
  has_many :player_snapshots, dependent: :destroy
end
