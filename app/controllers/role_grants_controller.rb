class RoleGrantsController < ApplicationController
  before_action :set_role_grant, only: [:show, :edit, :update, :destroy]

  # GET /role_grants
  # GET /role_grants.json
  def index
    @role_grants = RoleGrant.all
  end

  # GET /role_grants/1
  # GET /role_grants/1.json
  def show
  end

  # GET /role_grants/new
  def new
    @role_grant = RoleGrant.new
  end

  # GET /role_grants/1/edit
  def edit
  end

  # POST /role_grants
  # POST /role_grants.json
  def create
    @role_grant = RoleGrant.new(role_grant_params)

    respond_to do |format|
      if @role_grant.save
        format.html { redirect_to @role_grant, notice: 'Role grant was successfully created.' }
        format.json { render :show, status: :created, location: @role_grant }
      else
        format.html { render :new }
        format.json { render json: @role_grant.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /role_grants/1
  # PATCH/PUT /role_grants/1.json
  def update
    respond_to do |format|
      if @role_grant.update(role_grant_params)
        format.html { redirect_to @role_grant, notice: 'Role grant was successfully updated.' }
        format.json { render :show, status: :ok, location: @role_grant }
      else
        format.html { render :edit }
        format.json { render json: @role_grant.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /role_grants/1
  # DELETE /role_grants/1.json
  def destroy
    @role_grant.destroy
    respond_to do |format|
      format.html { redirect_to role_grants_url, notice: 'Role grant was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_role_grant
      @role_grant = RoleGrant.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def role_grant_params
      params.require(:role_grant).permit(:user_id, :role_id)
    end
end
