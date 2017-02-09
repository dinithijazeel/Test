class ProfilesController < ApplicationController
  respond_to :html, :js
  before_action :set_profile, only: [:show, :edit, :update, :destroy]

  # GET /profile/edit
  def edit
  end

  # PATCH/PUT /profile/1
  # PATCH/PUT /profile/1.json
  def update
    respond_to do |format|
      if @profile.update(profile_params)
        format.html { redirect_to edit_profile_path, notice: 'Profile was successfully updated.' }
        # format.json { render :show, status: :ok, location: @profile }
        # format.js { render :update }
      else
        format.html { render :edit }
        format.json { render json: @profile.errors, status: :unprocessable_entity }
        format.js { render :edit }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_profile
      @profile = current_user
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def profile_params
      params.require(:profile).permit(User.controller_profile_params)
    end
end
