class InvoicePolicy < ApplicationPolicy

  def index?
    user.is(:manager)
  end

  def show?
    user.is(:manager)
  end

  def create?
    user.is(:root)
  end

  def update?
    user.is(:manager)
  end

  def destroy?
    user.is(:admin)
  end

  def accept_payment?
    @record.invoice_status == 'open'
  end

  def rate?
    user.is(:admin)
  end
end
