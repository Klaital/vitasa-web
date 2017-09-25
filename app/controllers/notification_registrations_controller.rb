class NotificationRegistrationsController < ApplicationController
  before_action :set_notification_registration, only: [:show, :edit, :update, :destroy]

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
    @notification_registration = NotificationRegistration.new(notification_registration_params)

    respond_to do |format|
      if logged_in?
        @notification_registration.user_id = current_user.id
        if @notification_registration.save

          @notification_registration.register_sns

          format.html { redirect_to @notification_registration, notice: 'Notification registration was successfully created.' }
          format.json { render :show, status: :created, location: @notification_registration }
        else
          format.html { render :new }
          format.json { render json: @notification_registration.errors, status: :unprocessable_entity }
        end
      else
        format.html { render :file => 'public/401', :status => :unauthorized, :layout => false }
        format.json { render :json => {:errors => 'Unauthorized'}, :status => :unauthorized }
      end
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
      format.html { render :file => 'public/401', :status => :unauthorized, :layout => false }
      format.json { render :json => {:errors => 'Unauthorized'}, :status => :unauthorized }
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
