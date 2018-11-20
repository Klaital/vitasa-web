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
    @calendar = @site.calendars.new(calendar_params)
    respond_to do |format|
      if is_admin? || (logged_in? && current_user.id == @site.sitecoordinator && current_user.has_role?('SiteCoordinator'))
        if @calendar.save
          expire_schedule_cache
          format.html { redirect_to @site, notice: 'Calendar override was successfully created.' }
          format.json { render :show, status: :created, location: site_calendar_url(@site, @calendar) }
        else
          format.html { render :new }
          format.json { render json: @site.errors, status: :unprocessable_entity }
        end
      else
        format.html { render :file => 'public/401', :status => :unauthorized, :layout => false }
        format.json { render :json => {:errors => 'Unauthorized'}, :status => :unauthorized }
      end
    end
  end

  # PUT/PATCH /sites/{site_id}/calendars/{id}
  # PUT/PATCH /sites/{site_id}/calendars/{id}.json
  def update
    respond_to do |format|
      if is_admin? || (logged_in? && current_user.id == @site.sitecoordinator && current_user.has_role?('SiteCoordinator'))
        if @calendar.update(calendar_params)
          expire_schedule_cache
          format.html { redirect_to @site, notice: 'Calendar override was successfully updated.' }
          format.json { render :show, status: :ok, location: @site }
        else
          format.html do
            redirect_to @site
          end
          format.json { render json: @site.errors, status: :unprocessable_entity }
        end
      else
        format.html { render :file => 'public/401', :status => :unauthorized, :layout => false }
        format.json { render :json => {:errors => 'Unauthorized'}, :status => :unauthorized }
      end
    end
  end
  

  # DELETE /sites/{site_id}/calendars/{id}
  # DELETE /sites/{site_id}/calendars/{id}.json
  def destroy
    unless is_admin? || (logged_in? && current_user.id == @site.sitecoordinator && current_user.has_role?('SiteCoordinator'))
      render :json => { :errors => 'Not authorized'}, :status => :unauthorized
      response.set_header('Content-Type', 'application/json')
      return
    end

    @calendar.destroy
    expire_schedule_cache
    respond_to do |format|
      format.html { redirect_to site_url(@site), notice: 'Calendar override was successfully destroyed.' }
      format.json { head :no_content }
    end
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
