class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy ]
  skip_before_action :verify_authenticity_token
  wrap_parameters :user, include: [:password, :password_confirmation, :role_ids, :roles, :email, :phone, :certification, :name]

  def index
    @users = User.all

    respond_to do |format|
      if logged_in?
        format.html { render :index }
        format.json { render :index }
      else
        format.html { render :file => 'public/401', :status => :unauthorized, :layout => false }
        format.json { render json: { :errors => 'Not authorized' }, :status => :unauthorized }
      end
    end
  end

  def new
    @user = User.new
    respond_to do |format|
      format.html { render :new }
      format.json { render json: { errors: 'This is a web function. No JSON to be provided.'}, status: 406}
    end
  end
  def create
    @user = User.new(user_params)

    if @user.save
      # Create the starting role as well
      @user.roles = [ Role.find_by(name: 'NewUser') ]

      log_in @user
      respond_to do |format|
        format.html { flash[:success] = "Welcome, new user!"; redirect_to @user }
        format.json { render @user, status: 201 }
      end
    else
      respond_to do |format|
        format.html {render 'new'}
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /users/edit
  def edit
    unless logged_in? && (current_user == @user || is_admin?)
      render :json => { :errors => 'Not authorized'}, :status => :unauthorized
      response.set_header('Content-Type', 'application/json')
      return
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/0.json
  def update
    unless logged_in? && (current_user == @user || is_admin?)
      render :json => { :errors => 'Not authorized'}, :status => :unauthorized
      response.set_header('Content-Type', 'application/json')
      return
    end

    # Only update the Role Grants if any are set at all
    updated_roles = false
    if logged_in? && current_user.is_admin?
      logger.debug("Loading new roles...")
      new_roles = params.has_key?(:role_ids) ? (params[:role_ids].collect {|role_id| (role_id.blank?) ? nil : Role.find(role_id)}.compact) : []
      new_roles = params.has_key?(:roles) ? (params[:roles].collect {|role_name| Role.find_by(name: role_name)}).compact : []
      logger.debug("New Roleset: #{new_roles}")
      unless new_roles.empty?
        @user.roles = new_roles
        updated_roles = true
      end

    end

    # Check whether there is anything else for this user to update
#    if user_params.nil? || user_params.empty?
#      render :json => { :errors => 'No valid params for your role to update'}, :status => :unprocessable_entity
#      response.set_header('Content-Type', 'application/json')
#      return
#    end 
   
    # Only include the password fields if both are set 
    prepared_user_params = user_params
    logger.debug("Permitted params: #{prepared_user_params.inspect}")
    if prepared_user_params[:password] == '' || prepared_user_params[:password].nil?
      logger.debug("Removing password fields: #{prepared_user_params}")
      prepared_user_params.delete(:password)
      prepared_user_params.delete(:password_confirmation)
    end

   respond_to do |format|
      if (!prepared_user_params.empty? && @user.update(prepared_user_params)) || updated_roles
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
    respond_to do |format|
      if logged_in?
        format.html { render :show }
        format.json { render :show }
      else
        format.html { render :file => 'public/401', :status => :unauthorized, :layout => false }
        format.json { render :json => { :errors => 'Not authorized' }, :status => :unauthorized }
      end
    end
  end

  def destroy
    unless is_admin?
      render :json => { :errors => 'Not authorized'}, :status => :unauthorized
      response.set_header('Content-Type', 'application/json')
      return
    end

    if @user.delete
        format.html { redirect_to users_path, notice: 'User was successfully deleted.' }
        format.json { render :show, status: :ok, location: users_path }
      else
        format.html { render users_path }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
#    logger.debug("Raw User Params: #{params}")
#    logger.debug("User logged in? #{logged_in?}")
#    logger.debug("Users: current=#{current_user.id}, accessing=#{params[:id]}")
#    logger.debug("Accessing self? #{logged_in? && current_user == User.find(params[:id])}")

    permitted_fields = if !logged_in? || (logged_in? && current_user == User.find(params[:id]))
                         logger.debug("Permitting self-user fields")
                         [
                           :name, :email, :password, :password_confirmation, :phone
                         ]
                       elsif logged_in? && current_user.is_admin?
                         logger.debug("Permitting admin-only user fields")
                         [
                           :roles, :role_ids, :certification, :name, :password, :password_confirmation
                         ]
                       else
                         logger.debug("Permitting no user fields")
                         []
                       end

#    params[:user].merge!({'password' => params['password'], 'password_confirmation' => params['password_confirmation']})
    #params.require(:user).permit(:name, :email, :password, :password_confirmation, :certification, :phone, :role_ids, :roles)
    begin
      logger.debug("Permitting these fields: #{permitted_fields}")
      logger.debug("Filtered params: #{params.require(:user).permit(permitted_fields)}")
      params.require(:user).permit(permitted_fields)
    rescue ActionController::ParameterMissing => e
      logger.warning("No valid parameters were included for the UsersController to process")
      []
    end 
  end
end
