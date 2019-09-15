class OrganizationsController < ApplicationController
  self.page_cache_directory = File.join(Rails.root, 'public', 'cached_pages')
  caches_page :index

  # GET /organizations
  # GET /organizations.json
  def index
    @organizations = Organization.all
  end
end