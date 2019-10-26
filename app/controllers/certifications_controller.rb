class CertificationsController < ApplicationController
  before_action :set_certification, only: [:show, :update, :destroy]
  skip_before_action :verify_authenticity_token

  def index
    @certifications = if logged_in?
                        Certification.where(organization_id: current_user.organization_id)
                      else
                        Certification.all
                      end
  end

  def create
    unless logged_in? && current_user.has_role?(['Admin', 'SuperAdmin'])
      render :json => {:errors => 'Unauthorized'}, :status => :unauthorized
      return
    end

    @certification = Certification.new(certification_params)

    # Allow Admins only to create certs in their org, but superadmins can create them on any org
    unless current_user.has_role?(['SuperAdmin'])
      # Only actually overwrite the requested org ID if the user has one set.
      # SuperAdmins can change their Org at will, including setting it to null.
      @certification.organization_id = current_user.organization_id if current_user.organization_id != nil
    end

    if @certification.save(certification_params)
      render partial: 'certifications/certification', locals: {certification: @certification}
    else
      render json: @certification.errors, status: :bad_request
    end
  end

  def update
    unless logged_in? && current_user.has_admin?(@certification.organization_id)
      render :json => {:errors => 'Unauthorized'}, :status => :unauthorized
      return
    end

    if @certification.update(certification_params)
      head :ok
    else
      render json: @certification.errors, status: :bad_request
    end
  end

  def destroy
    unless logged_in? && current_user.has_admin?(@certification.organization_id)
      render :json => {:errors => 'Unauthorized'}, :status => :unauthorized
      return
    end

    @certification.delete
    head :no_content
  end

  private
    def set_certification
      @certification = Certification.find(params[:id])
    end

    def certification_params
      params.require(:certification).permit([:name])
    end
end