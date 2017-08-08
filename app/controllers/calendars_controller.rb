class CalendarsController < ApplicationController
    before_action :set_site

    before_action :set_eligible_sitecoordinators, only: [ :edit, :new ]
    skip_before_action :verify_authenticity_token
    
    def index
        @calendars = @site.calendars
    end
    

  private
    def set_site
      @site = if params[:site_id] =~ /\A\d+\z/
        Site.find(params[:site_id])
      else
        Site.find_by(slug: params[:site_id])
      end

      if @site.nil?
        respond_to do |format|
          format.html { render :file => 'public/404', :status => :not_found, :layout => false }
          format.json { render :json => {:errors => "Invalid ID or slug. Site not found for '#{params[:id]}'"}, :status => :not_found }
        end
        return
      end

    end
end
