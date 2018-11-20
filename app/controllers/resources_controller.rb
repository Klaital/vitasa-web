class ResourcesController < ApplicationController
  before_action :set_resource, only: [:show, :edit, :update, :destroy]
  before_action :check_permissions, only: [:edit, :update, :destroy, :new, :create]
  wrap_parameters :resource, include: [:slug, :text] + Resource.globalize_attribute_names

  skip_before_action :verify_authenticity_token
  
  # GET /resources
  # GET /resources.json
  def index
    @resources = Resource.all
  end

  # GET /resources/1
  # GET /resources/1.json
  def show
  end

  # GET /resources/new
  def new
    @resource = Resource.new
  end

  # GET /resources/1/edit
  def edit
  end

  # POST /resources
  # POST /resources.json
  def create
    @resource = Resource.new(resource_params)

    respond_to do |format|
      if @resource.save
        format.html { redirect_to @resource, notice: 'Resource was successfully created.' }
        format.json { render :show, status: :created, location: @resource }
      else
        format.html { render :new }
        format.json { render json: @resource.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /resources/1
  # PATCH/PUT /resources/1.json
  def update
    respond_to do |format|
      if @resource.update(resource_params)
        format.html { redirect_to @resource, notice: 'Resource was successfully updated.' }
        format.json { render :show, status: :ok, location: @resource }
      else
        format.html { render :edit }
        format.json { render json: @resource.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /resources/1
  # DELETE /resources/1.json
  def destroy
    @resource.destroy
    respond_to do |format|
      format.html { redirect_to resources_url, notice: 'Resource was successfully destroyed.' }
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

    def set_resource
      # Enable slug-based lookup
      @resource = if params[:id] =~ /\A\d+\z/
        Resource.find(params[:id])
      else
        Resource.find_by(slug: params[:id])
      end

      if @resource.nil?
        respond_to do |format|
          format.html { render :file => 'public/404', :status => :not_found, :layout => false }
          format.json { render :json => {:errors => "Invalid ID or slug. Resource not found for '#{params[:id]}'"}, :status => :not_found }
        end
        return
      end

    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def resource_params
      permitted_params = [:slug, :text] + Resource.globalize_attribute_names
      
      params.require(:resource).permit(*permitted_params)
    end
end
