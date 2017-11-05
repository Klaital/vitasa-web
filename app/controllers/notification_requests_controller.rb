class NotificationRequestsController < ApplicationController
  before_action :set_notification_request, only: [:resend_notification, :send_notification, :show, :edit, :update, :destroy]
  before_action :check_permissions, only: [:edit, :update, :destroy, :new, :create, :send_notification, :resend]
  skip_before_action :verify_authenticity_token
  wrap_parameters :notification_request, include: [:audience, :message]  

  # GET /notification_requests
  # GET /notification_requests.json
  def index
    @notification_requests = NotificationRequest.all
  end

  # GET /notification_requests/1
  # GET /notification_requests/1.json
  def show
  end

  # GET /notification_requests/new
  def new
    @notification_request = NotificationRequest.new
  end

  # GET /notification_requests/1/edit
  def edit
  end

  # POST /notification_requests
  # POST /notification_requests.json
  def create
    @notification_request = NotificationRequest.new(notification_request_params)

    respond_to do |format|
      if @notification_request.save
        format.html { redirect_to @notification_request, notice: 'Notification request was successfully created.' }
        format.json { render :show, status: :created, location: @notification_request }
      else
        format.html { render :new }
        format.json { render json: @notification_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /notification_requests/1/send
  def send_notification
    resp = @notification_request.send_broadcast
    respond_to do |format|
      if resp
        format.html { redirect_to @notification_request, notice: 'Notification sent.' }
        format.json { render :show, status: :ok, location: @notification_request }
      else
        format.html { redirect_to @notification_request, notice: 'Unable to send notification' }
        format.json {render :json => resp, status: 500 }
      end
    end
  end

  # POST /notification_requests/1//resend
  def resend_notification
    @notification_request.sent = nil
    @notification_request.save

    resp = @notification_request.send_broadcast
    respond_to do |format|
      if resp
        format.html { redirect_to @notification_request, notice: 'Notification sent.' }
        format.json { render :show, status: :ok, location: @notification_request }
      else
        format.html { redirect_to @notification_request, notice: 'Unable to send notification' }
        format.json {render :json => resp, status: 500 }
      end
    end
  end

  # PATCH/PUT /notification_requests/1
  # PATCH/PUT /notification_requests/1.json
  def update
    respond_to do |format|
      if @notification_request.update(notification_request_params)
        format.html { redirect_to @notification_request, notice: 'Notification request was successfully updated.' }
        format.json { render :show, status: :ok, location: @notification_request }
      else
        format.html { render :edit }
        format.json { render json: @notification_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /notification_requests/1
  # DELETE /notification_requests/1.json
  def destroy
    @notification_request.destroy
    respond_to do |format|
      format.html { redirect_to notification_requests_url, notice: 'Notification request was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def check_permissions
      unless is_admin?
        respond_to do |format|
          format.html { render :file => 'public/401', :status => :unauthorized, :layout => false }
          format.json { render :json => {:errors => "Unauthorized"}, :status => :unauthorized }
        end
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
