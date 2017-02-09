class UserPolicy < ApplicationPolicy

  def create?
    user.is(:admin)
  end

  def update?
    user.is(:admin) || @record.id == User.current.id
  end

  def destroy?
    user.is(:admin)
  end

  def become?
    user.is(:admin)
  end
end
