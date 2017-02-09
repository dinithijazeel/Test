#
# OnboardingController
#
class OnboardingController < ApplicationController
  respond_to :html, :js
  before_action :set_onboarding, :only => [:show, :edit, :update, :destroy]

  # GET /onboardings/1/edit
  def edit
    render :layout => false
  end

  # PATCH/PUT /onboardings/1
  def update
    respond_to do |format|
      if @onboarding.update(onboarding_params)
        format.js { helper_reload }
      else
        format.js { render :edit }
      end
    end
  end

  private

  def set_onboarding
    @onboarding = Onboarding.find(params[:id])
  end

  def onboarding_params
    params.require(:onboarding).permit(Onboarding.controller_params)
  end
end
