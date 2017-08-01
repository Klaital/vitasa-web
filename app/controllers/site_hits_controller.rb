require 'accumulator'
class SiteHitsController < ApplicationController
    before_action :set_site, only: [:show, :edit, :update, :destroy]
    skip_before_action :verify_authenticity_token

    def index
        @site_hits = SiteHit.where(timestamp: (Time.now - (3600*24))..(Time.now) ).order(:timestamp => :desc)
        @overall = {
            :duration => Accumulator.new,
            :view => Accumulator.new,
            :db => Accumulator.new,
        }
        @codes = {
            200 => {
            :duration => Accumulator.new,
            :view => Accumulator.new,
            :db => Accumulator.new,
        },
        }

        @site_hits.each do |site_hit|
            @codes[site_hit.status] = {
                :duration => Accumulator.new,
                :view => Accumulator.new,
                :db => Accumulator.new,
            } unless @codes.keys.include?(site_hit.status)

            @overall[:duration].data.push(site_hit.duration)
            @overall[:view].data.push(site_hit.view)
            @overall[:db].data.push(site_hit.db)
            @codes[site_hit.status][:duration].data.push(site_hit.duration)
            @codes[site_hit.status][:view].data.push(site_hit.view)
            @codes[site_hit.status][:db].data.push(site_hit.db)
        end
    end

    private
    # Use callbacks to share common setup or constraints between actions.
    def set_site_hit
      @site_hit = SiteHit.find(params[:id])
    end
end
