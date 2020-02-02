class NotificationRegistrationsController < ApplicationController
  before_action :set_notification_registration, only: [:show, :edit, :update, :destroy]
  skip_before_action :verify_authenticity_token
  wrap_parameters :notification_registration, include: [:token, :platform]

  # GET /notification_registrations
  # GET /notification_registrations.json
  def index
    @notification_registrations = NotificationRegistration.all
  end

  # GET /notification_registrations/1
  # GET /notification_registrations/1.json
  def show
  end

  # GET /notification_registrations/new
  def new
    @notification_registration = NotificationRegistration.new
  end

  # GET /notification_registrations/1/edit
  def edit
  end

  # POST /notification_registrations
  # POST /notification_registrations.json
  def create
    unless logged_in?
      render :json => {:errors => 'Unauthorized'}, :status => :unauthorized
      return
    end
    @notification_registration = NotificationRegistration.new(notification_registration_params)
    @notification_registration.user_id = current_user.id
    if !current_user.sms_optin && @notification_registration.platform == 'sms'
      render :json => {:errors => 'User has not opted in for SMS notifications'}, :status => :bad_request
      return
    end

    # Users with sms_optin turned on override any device push notifications
    if current_user.sms_optin && current_user.phone.length > 0
      logger.info("User #{current_user.email} has SMS Optin override")
      @notification_registration.platform = 'sms'
      @notification_registration.token = current_user.phone
    else
      logger.info("User #{current_user.email} does not have SMS Optin. Using given values: #{@notification_registration.platform} / #{@notification_registration.token}")
    end


    if @notification_registration.save

      @notification_registration.register_sns
      render :show, status: :created, location: @notification_registration
    else
      render json: @notification_registration.errors, status: :unprocessable_entity
    end
  end

  # DELETE /notification_registrations/1
  # DELETE /notification_registrations/1.json
  def destroy
    if logged_in? && @notification_registration.user_id == current_user.id
      @notification_registration.destroy
      respond_to do |format|
        format.html { redirect_to notification_registrations_url, notice: 'Notification registration was successfully destroyed.' }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { render :file => 'public/401', :status => :unauthorized, :layout => false }
        format.json { render :json => {:errors => 'Unauthorized'}, :status => :unauthorized }
      end
    end      
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_notification_registration
      @notification_registration = NotificationRegistration.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def notification_registration_params
      params.require(:notification_registration).permit(:token, :platform)
    end
end
