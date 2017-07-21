class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy ]

  def index
    @users = User.all
  end

  def new
    @user = User.new
  end
  def create
    @user = User.new(user_params)
    if @user.save
      # Create the starting role as well
      @user.roles = [ Role.find_by(name: 'NewUser') ]
      log_in @user
      flash[:success] = "Welcome, new user!"
      redirect_to @user
    else
      render 'new'
    end
  end

  # GET /users/edit
  def edit
    unless logged_in?
      return head 403
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    if user_params[:password] == ''
      user_params.delete(:password)
      user_params.delete(:password_confirmation)
    end

    # Only update the Role Grants if any are set at all
    new_roles = params[:user][:roles].collect {|role_id| (role_id.blank?) ? nil : Role.find(role_id)}.compact
    @user.roles = new_roles unless new_roles.empty?

    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
