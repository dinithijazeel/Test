class InvoicePolicy < ApplicationPolicy

  def index?
    user.is(:manager)
  end

  def show?
    user.is(:manager)
  end

  def create?
    user.is(:manager)
  end

  def update?
    user.is(:manager)
  end

end
