class CalendarsController < ApplicationController
  before_action :set_site
  before_action :set_calendar, only: [ :show, :destroy, :update ]
  skip_before_action :verify_authenticity_token
  
  # GET /sites/{site_id}/calendars
  # GET /sites/{site_id}/calendars.json
  def index
      @calendars = @site.calendars
  end
    
  # GET /sites/{site_id}/calendars/{id}
  # GET /sites/{site_id}/calendars/{id}.json
  def show
  end

  # POST /sites/{site_id}/calendars
  # POST /sites/{site_id}/calendars.json
  def create
    unless logged_in?
      logger.error("not allowed to delete a site calendar without being logged in")
      render :json => { :errors => 'Not authorized'}, :status => :unauthorized
      response.set_header('Content-Type', 'application/json')
      return
    end
    unless current_user.has_admin?(@site.organization_id) || @site.coordinators.include?(current_user)
      logger.error("Still not allowed to delete a calendar. Admin? #{is_admin?}. SC? #{@site.coordinators.include?(current_user)}")
      render :json => { :errors => 'Not authorized'}, :status => :unauthorized
      response.set_header('Content-Type', 'application/json')
      return
    end

    @calendar = @site.calendars.new(calendar_params)
    if @calendar.save
      render :show, status: :created, location: site_calendar_url(@site, @calendar)
    else
      render json: @site.errors, status: :unprocessable_entity
    end
  end

  # PUT/PATCH /sites/{site_id}/calendars/{id}
  # PUT/PATCH /sites/{site_id}/calendars/{id}.json
  def update
    unless logged_in?
      logger.error("not allowed to delete a site calendar without being logged in")
      render :json => { :errors => 'Not authorized'}, :status => :unauthorized
      response.set_header('Content-Type', 'application/json')
      return
    end
    unless current_user.has_admin?(@site.organization_id) || @site.coordinators.include?(current_user)
      logger.error("Still not allowed to delete a calendar. Admin? #{is_admin?}. SC? #{@site.coordinators.include?(current_user)}")
      render :json => { :errors => 'Not authorized'}, :status => :unauthorized
      response.set_header('Content-Type', 'application/json')
      return
    end

    if @calendar.update(calendar_params)
      render :show, status: :ok, location: @site
    else
      render json: @site.errors, status: :unprocessable_entity
    end
  end
  

  # DELETE /sites/{site_id}/calendars/{id}
  # DELETE /sites/{site_id}/calendars/{id}.json
  def destroy
    unless logged_in?
      logger.error("not allowed to delete a site calendar without being logged in")
      render :json => { :errors => 'Not authorized'}, :status => :unauthorized
      response.set_header('Content-Type', 'application/json')
      return
    end
    unless current_user.has_admin?(@site.organization_id) || @site.coordinators.include?(current_user)
      logger.error("Still not allowed to delete a calendar. Admin? #{is_admin?}. SC? #{@site.coordinators.include?(current_user)}")
      render :json => { :errors => 'Not authorized'}, :status => :unauthorized
      response.set_header('Content-Type', 'application/json')
      return
    end

    @calendar.destroy
    head :no_content
  end

  private
    def set_site
      @site = if params[:site_id] =~ /\A\d+\z/
        Site.find(params[:site_id])
      else
        Site.find_by(slug: params[:site_id])
      end

      if @site.nil?
        respond_to do |format|
          format.html { render :file => 'public/404', :status => :not_found, :layout => false }
          format.json { render :json => {:errors => "Invalid ID or slug. Site not found for '#{params[:id]}'"}, :status => :not_found }
        end
        return
      end
    end

    def set_calendar
      set_site if @site.nil?
      @calendar = @site.calendars.find(params[:id])
    end

    def calendar_params
      params.require(:calendar).permit(:date, 
            :open, :close, :is_closed, :notes,
            :efilers_needed
          )
    end
end
