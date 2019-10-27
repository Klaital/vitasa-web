class SitesController < ApplicationController
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
    if logged_in?
      filters[:organization_id] = current_user.organization_id
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

    unless logged_in?
      logger.error("Only a logged-in admin can create a site")
      render :json => {:errors => 'Not logged in'}, :status => :unauthorized
      return
    end

    unless current_user.has_role?(['Admin', 'SuperAdmin'])
      logger.error("Only an admin can create a site")
      render :json => {:errors => 'Not an admin'}, :status => :unauthorized
      return
    end
    # SuperAdmins can create resources in any org
    unless current_user.has_role?('SuperAdmin')
      @site.organization = current_user.organization
    end
    
    if @site.save
      @site.site_features = params[:site_features].collect {|f| SiteFeature.create(feature: f)} unless params[:site_features].nil?
      render :show, status: :created, location: @site
    else
      logger.error("Errors: #{@site.errors.to_hash.to_json}")
      # logger.debug("Raw request: #{request.body.read}")

      render json: @site.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /sites/1
  # PATCH/PUT /sites/1.json
  def update
    if @site.nil?
      render :json => {:errors => "Invalid ID or slug. Site not found for '#{params[:id]}'"}, :status => :not_found
      return
    end
    unless logged_in?
      render json: {errors: 'Must be logged in to update a site'}, status: :unauthorized
      return
    end
    if current_user.has_admin?(@site.organization_id) || (@site.coordinators.include?(current_user) && current_user.has_role?('SiteCoordinator'))
      @site.site_features = params[:site_features].collect {|f| SiteFeature.create(feature: f)} unless params[:site_features].nil?
      @site.site_features = params[:site_features].collect {|f| SiteFeature.create(feature: f)} unless params[:site_features].nil?
      @site.coordinators = User.where(:id => params[:sitecoordinators].collect{|x| x[:id]}) unless params[:sitecoordinators].nil?

      if @site.update(site_params)
        render :show, status: :ok, location: @site
      else
        render json: @site.errors, status: :unprocessable_entity
      end
    else
      render :json => {:errors => 'Unauthorized'}, :status => :unauthorized
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
        render :json => {:errors => "Invalid ID or slug. Site not found for '#{params[:id]}'"}, :status => :not_found
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
