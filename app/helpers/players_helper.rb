# frozen_string_literal: true

module PlayersHelper
  def display_change(change_value)
    return "" if change_value.nil? || change_value.zero?

    diff = change_value.round(2)
    color = diff > 0 ? "green" : "red"
    symbol = diff > 0 ? "▲" : "▼"

    content_tag(:span, "#{symbol} #{diff.abs}", style: "color: #{color}; font-size: 0.8em;")
  end
end
