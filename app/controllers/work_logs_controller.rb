class WorkLogsController < ApplicationController
  before_action :set_user, only: [:create, :update]
  before_action :set_worklog, only: [:update, :destroy]
  skip_before_action :verify_authenticity_token
  wrap_parameters :work_log, include: [:site, :hours, :date, :approved, :user_id]

  # POST /users/{id}/work_log
  def create
    logger.debug "Logging work for user: #{@user.id}"
    logger.debug "Logging work with settings: #{work_log_params}"
    wl = WorkLog.new(work_log_params.merge('user_id'=>@user.id))
    if wl.save
      wl.site.touch
      wl.user.touch
      render User.find(params[:user_id]), status: 201
    else
      render json: log.errors, status: :unprocessable_entity
    end
  end

  # PUT /users/{user_id}/work_log/{worklog_id}
  def update
    if @work_log.update(work_log_params)
      @work_log.site.touch
      @work_log.user.touch
      render json: @work_log, status: 201
    else
      render json: @work_log.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/{user_id}/work_log/{worklog_id}
  def destroy
    if @work_log.delete
      logger.debug "Manually expiring user/site view caches in the controller"
      @work_log.site.touch
      @work_log.user.touch
      head :ok
    else
      head 500
    end
  end

  def work_log_params
    logger.debug("Params: #{params}")
    worklog_params = params.require(:work_log).permit(:site, :hours, :date, :approved, :user_id)
    if worklog_params.include?(:site)
      site_id = Site.find_by(slug: worklog_params[:site]).id
      worklog_params.delete(:site)
      worklog_params.merge!({:site_id => site_id})
    end
    worklog_params
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:user_id])
  end
  def set_worklog
    @work_log = WorkLog.find(params[:id].to_i)
  end

end
