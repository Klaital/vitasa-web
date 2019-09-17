class SitesController < ApplicationController
  # self.page_cache_directory = File.join(Rails.root, 'public', 'cached_pages')
  caches_page :show, :new, :index

  before_action :set_site, only: [:show, :edit, :update, :destroy]
  before_action :set_eligible_sitecoordinators, only: [ :edit, :new ]
  skip_before_action :verify_authenticity_token

  # GET /sites
  # GET /sites.json
  def index
    filters = {
        :active => true
    }
    if params[:deactivated] == 'true'
      filters.delete(:active)
    end
    if params.has_key?(:organization_id)
      filters[:organization_id] = params[:organization_id]
    end
    if params.has_key?(:features) && !params[:features].empty?
      featured_sites = SiteFeature.where(:feature => @capabilities)
      filters[:id] = featured_sites.collect {|f| f.site_id}
    end

    @sites = if filters.empty?
               Site.all
             else
               Site.where(filters)
             end
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

    unless logged_in? && current_user.has_role?(['Admin', 'SuperAdmin'])
      format.json { render :json => {:errors => 'Unauthorized'}, :status => :unauthorized }
      return
    end
    # SuperAdmins can create resources in any org
    unless current_user.has_role?('SuperAdmin')
      @site.organization = current_user.organization
    end
    
    respond_to do |format|
      if @site.save
        # Expire the cache
        expire_page action: 'index'

      @site.site_features = params[:site_features].collect {|f| SiteFeature.create(feature: f)} unless params[:site_features].nil?
        format.html { redirect_to @site, notice: 'Site was successfully created.' }
        format.json { render :show, status: :created, location: @site }
      else
        logger.error("Errors: #{@site.errors.to_hash.to_json}")
        logger.debug("Raw request: #{request.body.read}")

        format.html do
          @eligible_sitecoordinators = User.all.map {|u| u.has_role?('SiteCoordinator') ? [u.email, u.id] : nil}.compact
          @eligible_sitecoordinators = [] unless @eligible_sitecoordinators
          render :new
        end
        format.json { render json: @site.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /sites/1
  # PATCH/PUT /sites/1.json
  def update
    respond_to do |format|
      if is_admin? || (logged_in? && current_user.has_role?('SiteCoordinator'))
        @site.site_features = params[:site_features].collect {|f| SiteFeature.create(feature: f)} unless params[:site_features].nil?
        @site.site_features = params[:site_features].collect {|f| SiteFeature.create(feature: f)} unless params[:site_features].nil?
        @site.coordinators = User.where(:id => params[:sitecoordinators].collect{|x| x[:id]}) unless params[:sitecoordinators].nil?

        if @site.update(site_params)
          # Expire the cache
          expire_page action: 'show', id: @site.id
          expire_page action: 'index'
          
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
    # only admins from the same Organization can delete sites
    unless (is_admin? && current_user.organization == @site.organization) || current_user.has_role?('SuperAdmin')
      render :json => { :errors => 'Not authorized'}, :status => :unauthorized
      response.set_header('Content-Type', 'application/json')
      return
    end

    @site.destroy
    # Expire the cache
    expire_page action: 'show', id: @site.id
    expire_page action: 'index'

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
      fields_permitted = [:name, :slug,
          :google_place_id, :street, :city, :state, :zip, :latitude, :longitude,
          :monday_open, :monday_close, :tuesday_open, :tuesday_close,
          :wednesday_open, :wednesday_close, :thursday_open, :thursday_close,
          :friday_open, :friday_close, :saturday_open, :saturday_close,
          :sunday_open, :sunday_close,

          :monday_efilers, :tuesday_efilers, :wednesday_efilers,
          :thursday_efilers, :friday_efilers, :saturday_efilers, :sunday_efilers,

          :site_features,

          :season_start, :season_end,
          :sitecoordinators,
          :contact_name, :contact_phone,
          :notes,
          :active]
      if logged_in? && current_user.has_role?('SuperAdmin')
        fields_permitted |= [:organization_id]
      end
      params.require(:site).permit(fields_permitted)
    end
end
