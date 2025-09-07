# frozen_string_literal: true

# This is not an ActiveRecord model. It's a plain Ruby object to represent a role.
class Role
  attr_reader :position, :role, :mentality, :side, :role_code

  def initialize(attributes)
    @position = attributes["position"]
    @role = attributes["role"]
    @mentality = attributes["mentality"]
    @side = attributes["side"]
    @role_code = attributes["role_code"]
    @attributes = attributes.except("position", "role", "mentality", "side", "role_code")
  end

  def [](key)
    return send(key) if ["position", "role", "mentality", "side", "role_code"].include?(key.to_s)

    @attributes[key]
  end

  def to_h
    @attributes.merge(
      "position" => @position,
      "role" => @role,
      "mentality" => @mentality,
      "side" => @side,
      "role_code" => @role_code,
    )
  end
end
