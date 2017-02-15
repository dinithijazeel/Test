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

  def use_stripe?
    user.is(:sales)
  end

  def use_bank_deposit?
    user.is(:admin)
  end

  def use_credit?
    user.is(:admin)
  end

end
