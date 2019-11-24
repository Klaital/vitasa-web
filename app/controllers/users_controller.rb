class UsersController < ApplicationController
  before_action :set_user, only: %i[show edit update destroy]
  skip_before_action :verify_authenticity_token
  wrap_parameters :user, include: %i[password password_confirmation role_ids roles email phone certification name subscribe_mobile organization_id sms_optin]

  def index
    filters = {}
    if logged_in?
      filters[:organization_id] = current_user.organization_id
    end
    if params.has_key?(:organization_id)
      filters[:organization_id] = params[:organization_id]
    end
    filters.compact!

    @users = if filters.empty?
               User.all
             else
               User.where(filters)
             end

    respond_to do |format|
      if logged_in?
        format.html { render :index }
        format.json { render :index }
      else
        format.html { render file: 'public/401', status: :unauthorized, layout: false }
        format.json { render json: { errors: 'Not authorized' }, status: :unauthorized }
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
    logger.debug "Raw request: #{request.body.read}"


    if params[:authcode].nil?
      render json: {errors: 'No authcode included in registration'}, status: :bad_request
      return
    end
    if params[:authcode].empty?
      render json: {errors: 'No authcode included in registration'}, status: :bad_request
      return
    end

    organization = Organization.find_by(authcode: params[:authcode])
    if organization.nil?
      render json: {errors: 'Invalid authcode'}, status: :bad_request
      return
    end


    permitted_fields = if logged_in? && current_user.has_role?(['Admin', 'SuperAdmin'])
                         %i[name email roles role_ids certification name
                         password password_confirmation
                         phone subscribe_mobile
                         international_certification military_certification
                         hsa_certification organization_id]
                       else
                         %i[ name email phone
                         password password_confirmation
                         organization_id ]
                       end

    fields = params.require(:user).permit(permitted_fields)
    fields[:organization_id] = organization.id
    @user = User.new(fields)

    # If the creating user is a SuperAdmin, they can set the org ID.
    # Anyone else creating a user (i.e. the org admins) will create
    # that user in their own org, regardless of what data they submit.
    if logged_in? && !current_user.has_role?('SuperAdmin')
      @user.organization_id = current_user.organization_id
    end

    if @user.save
      respond_to do |format|
        format.html { log_in @user; flash[:success] = 'Welcome, new user!'; redirect_to @user }
        format.json { render @user, status: 201 }
      end
    else
      respond_to do |format|
        logger.error("Errors: #{@user.errors.to_hash.to_json}")
        format.html {render 'new'}
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /users/edit
  def edit
    unless logged_in?
      render json: { errors: 'Not authorized'}, status: :unauthorized
      response.set_header('Content-Type', 'application/json')
      return
    end

    # Users can edit themselves.
    # Admins can only be edited/deleted by superadmins.
    # Regular users can be edited by their own admins or superadmins.
    authorized = if current_user == @user
                   true
                 elsif @user.has_role?('Admin', 'SuperAdmin')
                   current_user.has_role?('SuperAdmin')
                 else
                   current_user.has_role?('Admin', 'SuperAdmin')
                 end
    unless authorized
      render json: { errors: 'Not authorized'}, status: :unauthorized
      response.set_header('Content-Type', 'application/json')
      return
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/0.json
  def update
    unless logged_in?
      logger.error('Not logged in')
      render json: { errors: 'Not logged in'}, status: :unauthorized
      response.set_header('Content-Type', 'application/json')
      return
    end
    unless current_user == @user || current_user.has_admin?(@user.organization_id)
      logger.error('Not authorized to edit this user')
      render json: { errors: 'Not authorized to edit this user'}, status: :unauthorized
      response.set_header('Content-Type', 'application/json')
      return
    end


    # Only update the Role Grants if any are set at all
    if params.has_key?(:roles) && !current_user.has_admin?(@user.organization_id)
      # Only Org Admins are allowed to set Roles
      logger.error('Only org admins may set roles')
      render json: {errors: 'Only org admins may set roles'}, status: :unauthorized
      return
    end
    updated_roles = false
    if current_user.has_admin?(@user.organization_id)
      logger.debug('Loading new roles...')
#      role_params = params.require(:user).permit([:role_ids, :roles])
      new_roles = if params.has_key?(:role_ids)
                   (params[:role_ids].collect {|role_id| Role.find(role_id)}.compact)
                 elsif params.has_key?(:roles)
                   (params[:roles].collect {|role_name| Role.find_by(name: role_name)}).compact
                 else 
                   []
                 end
      logger.debug("New Roleset: #{new_roles}")
      unless new_roles.empty?
        @user.roles = new_roles
        @user.touch
        updated_roles = true
      end
    end

    if current_user == @user || current_user.has_admin?(@user.organization_id)
      # Update their preferred sites, if set
      if params.has_key?(:preferred_sites)
        @user.preferred_sites = Site.where(slug: params[:preferred_sites])
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
    if !prepared_user_params.empty? && prepared_user_params[:password] == '' || prepared_user_params[:password].nil?
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
        format.html { render file: 'public/401', status: :unauthorized, layout: false }
        format.json { render json: { errors: 'Not authorized' }, status: :unauthorized }
      end
    end
  end

  def destroy
    # Users can edit themselves.
    # Admins can only be edited/deleted by superadmins.
    # Regular users can be edited by their own admins or superadmins.
    authorized = if current_user == @user
                   true
                 elsif @user.has_role?(['Admin', 'SuperAdmin'])
                   current_user.has_role?('SuperAdmin')
                 else
                   current_user.has_role?(['Admin', 'SuperAdmin']) && current_user.organization == @user.organization
                 end
    unless authorized
      render json: { errors: 'Not authorized'}, status: :unauthorized
      response.set_header('Content-Type', 'application/json')
      return
    end

    if @user.delete
      head :ok
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  def log_work

    log = WorkLog.new(work_log_params.merge)
    if log.save
      render @user, status: 201
    else
      render json: log.errors, status: :unprocessable_entity
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end


  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    logger.debug("Raw User Params: #{params}")
    logger.debug("User logged in? #{logged_in?}")
    logger.debug()
    unless logged_in?
      logger.error("No logged-in user")
      return []
    else
      logger.debug("Logged-in user: #{current_user.email}")
    end

    logger.debug("Users: current=#{current_user.id}, accessing=#{params[:id]}")
    logger.debug("Accessing self? #{current_user.id == params[:id].to_i}")
    logger.debug("Admin? #{current_user.is_admin?}")

    permitted_fields = if current_user.has_role?('SuperAdmin')
                         logger.debug('Permitting superadmin user fields')
                         %i[name email roles role_ids certification name password
                            password_confirmation phone subscribe_mobile
                            organization_id sms_optin]
                        elsif current_user.is_admin?
                         logger.debug('Permitting admin-only user fields')
                         %i[name email roles role_ids certification name password
                            password_confirmation phone subscribe_mobile
                            sms_optin]
                       elsif current_user.id == params[:id].to_i
                         logger.debug('Permitting self-user fields')
                         %i[name email password password_confirmation phone
                            subscribe_mobile sms_optin]
                       else
                         logger.debug('Permitting no user fields')
                         []
                       end
    if logged_in? && current_user.is_admin?
      logger.debug('Adding Admin fields')
      permitted_fields |= %i[email roles role_ids certification
                             password password_confirmation]
    end

    begin
      logger.debug("Permitting these fields: #{permitted_fields}")
      logger.debug("Filtered params: #{params.require(:user).permit(permitted_fields)}")
      params.require(:user).permit(permitted_fields)
    rescue ActionController::ParameterMissing => e
      logger.warn("No valid parameters were included for the UsersController to process: #{e}")
      {}
    end
  end
end
