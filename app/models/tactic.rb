# frozen_string_literal: true

class Tactic < ApplicationRecord
  has_many :tactic_roles, dependent: :destroy
  accepts_nested_attributes_for :tactic_roles

  # ADD THIS VALIDATION
  validates :name, presence: true
end
