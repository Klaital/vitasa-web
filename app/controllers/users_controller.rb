class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy ]
  skip_before_action :verify_authenticity_token

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
    merged_user_params = user_params.merge({'password' => params['password'], 'password_confirmation' => params['password_confirmation']})

    @user = User.new(merged_user_params)
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
  # PATCH/PUT /users/1.json
  def update
    unless logged_in? && (current_user == @user || is_admin?)
      render :json => { :errors => 'Not authorized'}, :status => :unauthorized
      response.set_header('Content-Type', 'application/json')
      return
    end
    
    prepared_user_params = user_params.dup
    if prepared_user_params[:password] == '' || prepared_user_params[:password].nil?
      prepared_user_params.delete(:password)
      prepared_user_params.delete(:password_confirmation)
    end


    # Only update the Role Grants if any are set at all
    new_roles = params.has_key?(:role_ids) ? (params[:role_ids].collect {|role_id| (role_id.blank?) ? nil : Role.find(role_id)}.compact) : []
    @user.roles = new_roles unless new_roles.empty?

    respond_to do |format|
      if @user.update(prepared_user_params)
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
    unless @user.nil?
      @work_history = Signup.where('user_id = :user_id AND date < :date', {:user_id => @user.id, :date => Date.today}).order(:date => :asc)
      @work_intents = Signup.where('user_id = :user_id AND date >= :date', {:user_id => @user.id, :date => Date.today}).order(:date => :asc)
      @suggestions  = Suggestion.where(user_id: @user.id)
    end
  end

  def self.user_metadata(user_id)
    work_history = Signup.where('user_id = :user_id AND date < :date', {:user_id => user_id, :date => Date.today}).order(:date => :asc)
    work_intents = Signup.where('user_id = :user_id AND date >= :date', {:user_id => user_id, :date => Date.today}).order(:date => :asc)
    suggestions  = Suggestion.where(user_id: user_id)
    [ work_history, work_intents, suggestions ]
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    logger.info("Raw User Params: #{params}")
    params[:user].merge!({'password' => params['password'], 'password_confirmation' => params['password_confirmation']})
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :certification, :phone)
  end
end
