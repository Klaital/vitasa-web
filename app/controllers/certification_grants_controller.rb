class CertificationGrantsController < ApplicationController
  before_action :set_user, only: [:create, :destroy]
  skip_before_action :verify_authenticity_token

  def create
    unless logged_in? && current_user.has_admin?(@user.organization_id)
      render :json => {:errors => 'Unauthorized'}, :status => :unauthorized
      return
    end
    unless @user.organization_id == @certification.organization_id
      logger.error("Certification and User are in different Orgs")
      render :json => {:errors => 'Bad Request: Certification and User are in different Organizations'}, status: :bad_request
      return
    end
    grant = CertificationGrant.new(certification_id: @certification.id, user_id: @user.id)
    if grant.save
      head :ok
    else
      render :json => {:errors => grant.errors}, status: :unprocessable_entity
    end
  end

  def destroy
    unless logged_in? && current_user.has_admin?(@user.organization_id)
      render json: {errors: 'Unauthorized'}, status: :unauthorized
      return
    end

    grant = CertificationGrant.find_by(user_id: @user.id, certification_id: @certification.id)
    if grant.nil?
      head :not_found
      return
    end

    if grant.delete
      @user.touch # manually expire the user view cache
      head :ok
    else
      render :json => {:errors => 'Could not delete grant'}, status: :internal_server_error
    end
  end


  private

  def set_user
    @user = User.find(params[:user_id])
    @certification = Certification.find(params[:id])
  end
end
