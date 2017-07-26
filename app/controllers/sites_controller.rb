class SitesController < ApplicationController
  before_action :set_site, only: [:show, :edit, :update, :destroy]
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
    @eligible_sitecoordinators = User.all.map {|u| u.has_role?('SiteCoordinator') ? u : nil}.compact
    @eligible_sitecoordinators = [] unless @eligible_sitecoordinators

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
    @eligible_sitecoordinators = User.all.map {|u| u.has_role?('SiteCoordinator') ? [u.email, u.id] : nil}.compact
    @eligible_sitecoordinators = [] unless @eligible_sitecoordinators

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
    
    respond_to do |format|
      if is_admin?
        if @site.save
          format.html { redirect_to @site, notice: 'Site was successfully created.' }
          format.json { render :show, status: :created, location: @site }
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

  # PATCH/PUT /sites/1
  # PATCH/PUT /sites/1.json
  def update
    respond_to do |format|
      if is_admin? || (logged_in? && current_user.id = @site.sitecoordinator && current_user.has_role?('SiteCoordinator'))
        if @site.update(site_params)
          format.html { redirect_to @site, notice: 'Site was successfully updated.' }
          format.json { render :show, status: :ok, location: @site }
        else
          format.html { render :edit }
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
      @site = Site.find(params[:id])
      @sitecoordinator = if @site.sitecoordinator.nil?
        nil
      else
        User.find(@site.sitecoordinator)
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def site_params
      params.require(:site).permit(:name, 
        :google_place_id, :street, :city, :state, :zip, :latitude, :longitude, 
        :sitecoordinator, :sitestatus)
    end
end
