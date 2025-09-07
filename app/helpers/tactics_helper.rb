# frozen_string_literal: true

module TacticsHelper
  def role_options
    # REFACTORED: Use the efficient, cached RoleData service
    # instead of reading the file on every call.
    RoleData.all_roles.sort_by { |r| [r.position, r.role, r.mentality] }
  end
end
