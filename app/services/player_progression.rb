# frozen_string_literal: true

# This service calculates all the data needed for a player's progression page.
class PlayerProgression
  attr_reader :player

  def initialize(player)
    @player = player
    # Eager load all snapshots in chronological order to avoid extra database queries
    @snapshots = player.player_snapshots.order(snapshot_date: :asc)
  end

  def joined_date
    first_snapshot&.snapshot_date
  end

  # This is the main method that calculates all attribute changes.
  def attribute_changes
    # Use memoization to cache the results so we don't recalculate every time
    @attribute_changes ||= DataImporter::PLAYER_ATTRIBUTES.to_h do |attr|
      current_value = current_snapshot[attr] || 0
      previous_value = previous_snapshot[attr] || 0
      first_value = first_snapshot[attr] || 0

      changes = {
        current_value: current_value,
        change_since_previous: current_value - previous_value,
        change_since_first: current_value - first_value,
      }
      [attr.to_sym, changes]
    end
  end

  private

  def current_snapshot
    @snapshots.last || PlayerSnapshot.new
  end

  def previous_snapshot
    # The second to last snapshot, or the first if there's only one
    @snapshots.length > 1 ? @snapshots[-2] : first_snapshot
  end

  def first_snapshot
    @snapshots.first || PlayerSnapshot.new
  end
end
