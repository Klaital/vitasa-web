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
    unless is_admin?
      return head 403
    end

    @site = Site.new
  end

  # GET /sites/1/edit
  def edit
    unless is_admin?
      return head 403
    end

  end

  # POST /sites
  # POST /sites.json
  def create
    unless is_admin?
      return head 403
    end

    @site = Site.new(site_params)

    respond_to do |format|
      if @site.save
        format.html { redirect_to @site, notice: 'Site was successfully created.' }
        format.json { render :show, status: :created, location: @site }
      else
        format.html { render :new }
        format.json { render json: @site.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /sites/1
  # PATCH/PUT /sites/1.json
  def update
    if not logged_in?
      render :json => { :errors => 'No user logged in'}, :status => 403
      response.set_header('Content-Type', 'application/json')
      return
    end
    unless is_admin?
      render :json => { :errors => 'Not an admin logged in'}, :status => 403
      response.set_header('Content-Type', 'application/json')
      return
    end

    respond_to do |format|
      if @site.update(site_params)
        format.html { redirect_to @site, notice: 'Site was successfully updated.' }
        format.json { render :show, status: :ok, location: @site }
      else
        format.html { render :edit }
        format.json { render json: @site.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sites/1
  # DELETE /sites/1.json
  def destroy
    unless is_admin?
      return head 403
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
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def site_params
      params.require(:site).permit(:name, :street, :city, :state, :zip, :latitude, :longitude, :sitecoordinator, :sitestatus)
    end
end
