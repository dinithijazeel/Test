class ProductPolicy < ApplicationPolicy

  def create?
    user.is(:admin)
  end

  def update?
    user.is(:admin)
  end

  def destroy?
    user.is(:admin)
  end

end
