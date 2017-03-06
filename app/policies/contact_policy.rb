class ContactPolicy < ApplicationPolicy
  def update?
    user.is(:sales)
  end
end
