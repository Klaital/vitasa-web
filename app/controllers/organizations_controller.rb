class OrganizationsController < ApplicationController
  skip_before_action :verify_authenticity_token
  # GET /organizations
  # GET /organizations.json
  def index
    @organizations = Organization.all
  end

  def create
    unless logged_in?
      logger.error("Must be logged in to create organization")
      render json: {errors: "Must be logged in to create organization"}, status: :unauthorized
      return
    end
    unless current_user.has_role?(['SuperAdmin'])
      logger.error("Must be a SuperAdmin to create organization")
      render json: {errors: "Must be a SuperAdmin to create organization"}, status: :unauthorized
      return
    end

    org = Organization.new(name: params[:name])
    if org.save
      head :ok
    else
      render json: {errors: org.errors}, status: :bad_request
    end
  end

  def destroy
    unless logged_in?
      logger.error("Must be logged in to destroy an organization")
      render json: {errors: "Must be logged in to destroy an organization"}, status: :unauthorized
      return
    end
    unless current_user.has_role?(['SuperAdmin'])
      logger.error("Must be a SuperAdmin to destroy an organization")
      render json: {errors: "Must be a SuperAdmin to destroy an organization"}, status: :unauthorized
      return
    end

    org = Organization.find(params[:id])
    if org.delete
      head :ok
    else
      # We should not get here, as the Organization.find will generate a 404 error if the ID is invalid.
      render json: {errors: org.errors}, status: :bad_request
    end
  end
end
