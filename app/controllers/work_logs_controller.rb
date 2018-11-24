class WorkLogsController < ApplicationController
  before_action :set_user, only: [:create, :update]
  before_action :set_worklog, only: [:update]
  skip_before_action :verify_authenticity_token
  wrap_parameters :work_log, include: [:site, :start_time, :end_time, :approved]

  # POST /users/{id}/work_log
  def create
    if @user.work_logs.create(work_log_params)
      respond_to do |format|
        format.html { flash[:success] = "Work logged!"; redirect_to @user }
        format.json { render User.find(params[:user_id]), status: 201 }
      end
    else
      respond_to do |format|
        format.html { render @user }
        format.json { render json: log.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /users/{user_id}/work_log/{worklog_id}
  def update
    if @work_log.update(work_log_params)
      respond_to do |format|
        format.json { render @user, status: 201 }
      end
    else
      respond_to do |format|
        format.json { render json: log.errors, status: :unprocessable_entity }
      end
    end
  end

  def work_log_params
    worklog_params = params.require(:work_log).permit(:site, :start_time, :end_time, :approved)
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
