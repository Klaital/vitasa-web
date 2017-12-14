class SitesController < ApplicationController
  self.page_cache_directory = File.join(Rails.root, 'public', 'cached_pages')
  caches_page :show, :new, :index

  before_action :set_site, only: [:show, :edit, :update, :destroy]
  before_action :set_eligible_sitecoordinators, only: [ :edit, :new ]
  skip_before_action :verify_authenticity_token

  # GET /sites
  # GET /sites.json
  def index
    @sites = Site.all
  end

  # GET /sites/1
  # GET /sites/1.json
  def show
  end

  # GET /sites/new
  def new
    @site = Site.new
    respond_to do |format|
      if is_admin?
        format.html { render :new }
        format.json { render json: { :errors => 'This is a web function. No JSON to be provided.'}, :status => 406}
      else
        format.html { render :file => 'public/401', :status => :unauthorized, :layout => false }
        format.json { render json: { :errors => 'Not authorized' }, :status => :unauthorized }
      end
    end
  end

  # GET /sites/1/edit
  def edit

    respond_to do |format|
      if logged_in? && (is_admin? || @site.sitecoordinator == current_user.id)
        format.html { render :edit }
        format.json { render json: { :errors => 'This is a web function. No JSON to be provided.'}, :status => 406}
      else
        format.html { render :file => 'public/401', :status => :unauthorized, :layout => false }
        format.json { render json: { :errors => 'Not authorized' }, :status => :unauthorized }
      end
    end
  end

  # POST /sites
  # POST /sites.json
  def create
    @site = Site.new(site_params)
    if @site.slug.to_s.strip.empty?
      @site.slug = @site.name.parameterize
    end
    
    respond_to do |format|
      if is_admin?
        if @site.save
          # Expire the cache
          expire_page action: 'index'
          expire_page controller: 'aggregates', action: 'schedule'

         @site.site_features = params[:site_features].collect {|f| SiteFeature.create(feature: f)} unless params[:site_features].nil?
          format.html { redirect_to @site, notice: 'Site was successfully created.' }
          format.json { render :show, status: :created, location: @site }
        else
          format.html do
            @eligible_sitecoordinators = User.all.map {|u| u.has_role?('SiteCoordinator') ? [u.email, u.id] : nil}.compact
            @eligible_sitecoordinators = [] unless @eligible_sitecoordinators
            render :new
          end
          format.json { render json: @site.errors, status: :unprocessable_entity }
        end
      else
        format.html { render :file => 'public/401', :status => :unauthorized, :layout => false }
        format.json { render :json => {:errors => 'Unauthorized'}, :status => :unauthorized }
      end
    end
  end

  # PATCH/PUT /sites/1
  # PATCH/PUT /sites/1.json
  def update
    respond_to do |format|
      if is_admin? || (logged_in? && current_user.id == @site.sitecoordinator && current_user.has_role?('SiteCoordinator'))
        @site.site_features = params[:site_features].collect {|f| SiteFeature.create(feature: f)} unless params[:site_features].nil?
        
        if @site.update(site_params)
          # Expire the cache
          expire_page action: 'show', id: @site.id
          expire_page action: 'index'
          expire_page action: 'schedule', controller: 'aggregates'

          format.html { redirect_to site_path(@site.slug), notice: 'Site was successfully updated.' }
          format.json { render :show, status: :ok, location: @site }
        else
          format.html do
            @eligible_sitecoordinators = User.all.map {|u| u.has_role?('SiteCoordinator') ? [u.email, u.id] : nil}.compact
            @eligible_sitecoordinators = [] unless @eligible_sitecoordinators
            render :edit
          end
          format.json { render json: @site.errors, status: :unprocessable_entity }
        end
      else
        format.html { render :file => 'public/401', :status => :unauthorized, :layout => false }
        format.json { render :json => {:errors => 'Unauthorized'}, :status => :unauthorized }
      end
    end
  end

  # DELETE /sites/1
  # DELETE /sites/1.json
  def destroy
    unless is_admin?
      render :json => { :errors => 'Not authorized'}, :status => :unauthorized
      response.set_header('Content-Type', 'application/json')
      return
    end

    @site.destroy
    respond_to do |format|
      format.html { redirect_to sites_url, notice: 'Site was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_site
      @site = if params[:id] =~ /\A\d+\z/
        Site.find(params[:id])
      else
        Site.find_by(slug: params[:id])
      end

      if @site.nil?
        respond_to do |format|
          format.html { render :file => 'public/404', :status => :not_found, :layout => false }
          format.json { render :json => {:errors => "Invalid ID or slug. Site not found for '#{params[:id]}'"}, :status => :not_found }
        end
        return
      end

      @work_history = Signup.where('site_id = :site_id AND date < :date', {:site_id => @site.id, :date => Date.today}).order(:date => :asc)
      @work_intents = Signup.where('site_id = :site_id AND date >= :date', {:site_id => @site.id, :date => Date.today}).order(:date => :asc)
      

      @sitecoordinator = if @site.sitecoordinator.nil?
        nil
      else
        User.find(@site.sitecoordinator)
      end

      @backup_coordinator = if @site.backup_coordinator_id.nil?
        nil
      else
        User.find(@site.backup_coordinator_id)
      end

      @work_history, @work_intents = site_signup_metadata(@site.id)
    end

    def site_signup_metadata(site_id)
      [ Site.find(site_id).work_history, Site.find(site_id).work_intents ]
    end


    def set_eligible_sitecoordinators
      @eligible_sitecoordinators = User.all.map {|u| u.has_role?('SiteCoordinator') ? [u.name, u.id] : nil}.compact
      @eligible_sitecoordinators = [] unless @eligible_sitecoordinators
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def site_params
      params.require(:site).permit(:name, :slug,
        :google_place_id, :street, :city, :state, :zip, :latitude, :longitude, 
        :sitecoordinator, :backup_coordinator_id, :sitestatus,
        :monday_open, :monday_close, :tuesday_open, :tuesday_close,
        :wednesday_open, :wednesday_close, :thursday_open, :thursday_close,
        :friday_open, :friday_close, :saturday_open, :saturday_close,
        :sunday_open, :sunday_close,

        :monday_efilers, :tuesday_efilers, :wednesday_efilers, 
        :thursday_efilers, :friday_efilers, :saturday_efilers, :sunday_efilers,

        :site_features,

        :season_start, :season_end
        )
    end
end
