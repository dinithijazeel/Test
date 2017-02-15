class ContactPolicy < ApplicationPolicy

  def update?
    @record.portal_id.blank?
  end
end
