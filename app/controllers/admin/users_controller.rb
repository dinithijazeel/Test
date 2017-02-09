class Admin::UsersController < ApplicationController
  before_action :set_user, :only => [:show, :edit, :update]

  # GET /users
  # GET /users.json
  def index
    if params[:q]
      @users = User.search(params[:q])
    else
      @users = User.index
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
    authorize @user
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)
    @user.password = (('a'..'z').to_a * 5).sample(50).join

    respond_to do |format|
      if @user.save
        format.html { redirect_to admin_users_path, :notice => 'User was successfully created.' }
        format.json { render :show, :status => :created, :location => @user }
      else
        format.html { render :new }
        format.json { render :json => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    authorize @user
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to admin_users_path, :notice => 'User was successfully updated.' }
        format.json { render :show, :status => :ok, :location => @user }
      else
        format.html { render :edit }
        format.json { render :json => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    # Get user, even if it's deleted
    @user = User.with_deleted.find(params[:id])
    # Disable or enable accordingly
    if @user.deleted?
      @user.restore
      message = 'User was successfully enabled.'
    else
      @user.destroy
      message = 'User was successfully disabled.'
    end
    respond_to do |format|
      format.html { redirect_to admin_users_path, :notice => message }
      format.json { head :no_content }
    end
  end

  def become
    return unless current_user.is(:admin)
    alias_user = User.find(params[:user_id])
    sign_in(:user, alias_user, :bypass => true)
    redirect_to root_url, :notice => "You are now logged in as #{alias_user.email}"
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(
      :role,
      :email,
      :title,
      :first_name,
      :last_name,
      :phone,
      :nickname,
      :about
    )
  end
end
