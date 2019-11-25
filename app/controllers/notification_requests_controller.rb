class NotificationRequestsController < ApplicationController
  before_action :set_notification_request, only: [:resend_notification, :send_notification, :show, :edit, :update, :destroy]
  before_action :check_permissions, only: [:edit, :update, :destroy, :new, :create, :send_notification, :resend]
  skip_before_action :verify_authenticity_token
  wrap_parameters :notification_request, include: [:audience, :message]  

  # GET /notification_requests
  # GET /notification_requests.json
  def index
    @notification_requests = if logged_in?
                               NotificationRequest.where(organization_id: current_user.organization_id)
                             else
                               NotificationRequest.all
                             end
  end

  # GET /notification_requests/1
  # GET /notification_requests/1.json
  def show
  end

  # POST /notification_requests
  # POST /notification_requests.json
  def create
    unless logged_in?
      render json: { errors: 'Not logged in'}, status: :unauthorized
      return
    end
    @notification_request = NotificationRequest.new(notification_request_params)
    @notification_request.organization_id = current_user.organization_id

    if @notification_request.save
      render json: @notification_request, status: :created
    else
      render json: @notification_request.errors, status: :unprocessable_entity
    end
  end

  # POST /notification_requests/1/send
  def send_notification
    unless logged_in?
      render json: { errors: 'Not logged in'}, status: :unauthorized
      return
    end

    resp = @notification_request.send_broadcast
    if resp
      render :show, status: :ok, location: @notification_request 
    else
      render :json => resp, status: 500 
    end
  end

  # POST /notification_requests/1/resend
  def resend_notification
    @notification_request.sent = nil
    @notification_request.save

    resp = @notification_request.send_broadcast
    if resp
      render :show, status: :ok, location: @notification_request
    else
      render :json => resp, status: 500 
    end
  end

  # PATCH/PUT /notification_requests/1
  # PATCH/PUT /notification_requests/1.json
  def update
    unless logged_in? && current_user.has_admin?(@notification_request.organization_id)
      render json: { errors: 'Must be org admin to update notification requests' }, status: :unauthorized
      return
    end

    if @notification_request.update(notification_request_params)
      render :show, status: :ok, location: @notification_request
    else
      render json: @notification_request.errors, status: :unprocessable_entity
    end
  end

  # DELETE /notification_requests/1
  # DELETE /notification_requests/1.json
  def destroy
    @notification_request.destroy
      head :no_content
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def check_permissions
      unless logged_in? && current_user.has_role?(['Admin'])
        render :json => {:errors => "Unauthorized"}, :status => :unauthorized 
        return
      end
    end

    def set_notification_request
      @notification_request = NotificationRequest.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def notification_request_params
      params.require(:notification_request).permit(:audience, :message)
    end
end

