class PaymentPolicy < ApplicationPolicy
  def create?
    user.is(:sales)
  end

  def update?
    user.is(:root)
  end

  def redistribute?
    @record.credit?
  end

  def destroy?
    user.is(:root)
  end
end
