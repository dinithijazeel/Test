class ApplicationController < ActionController::Base
  #
  ## Pundit
  #
  include Pundit
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  #
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  #
  protect_from_forgery :with => :null_session

  before_action :authenticate_user!

  before_filter :set_current_user, :prepend_view_paths
  after_filter -> { flash.discard }, :if => -> { request.xhr? }

  private

  def reorder_params
    params.require(:reorder).permit(:id, :position)
  end

  def set_current_user
    User.current = current_user
  end

  def prepend_view_paths
    prepend_view_path "app/views/tenants/#{Conf.tenant}"
  end

  def assign_creator
    self.creator = current_user
  end

  def assign_last_editor
    self.last_editor = current_user
  end

  def helper_reload
    render :inline => 'h.reload();'
  end

  def user_not_authorized
    flash[:alert] = 'You are not authorized to perform this action.'
    redirect_to(request.referrer || root_path)
  end
end
