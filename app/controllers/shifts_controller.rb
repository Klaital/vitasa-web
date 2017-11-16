class ShiftsController < ApplicationController
  before_action :set_shift, only: [:show, :edit, :update, :destroy]
  skip_before_action :verify_authenticity_token
  wrap_parameters :shift

  # GET /shifts
  # GET /shifts.json
  def index
    @shifts = Shift.all
  end

  # GET /shifts/1
  # GET /shifts/1.json
  def show
  end

  # GET /shifts/new
  def new
    @shift = Shift.new
  end

  # GET /shifts/1/edit
  def edit
  end

  # POST /shifts
  # POST /shifts.json
  def create
    @site = if params.has_key?(:site_slug)
              Site.find_by(slug: params[:site_slug])
            elsif params.has_key?(:site_id) && params[:site_id] =~ /\A\d+\Z/
              Site.find(params[:site_id])
            else
              Site.find_by(slug: params[:site_id])
            end
    @calendar = @site.calendars.find(params[:calendar_id])
    @shift = @calendar.shifts.new(shift_params)

    respond_to do |format|
      if @shift.save
        format.html { redirect_to site_calendar_shift_path(@site.slug, @calendar, @shift), notice: 'Shift was successfully created.' }
        format.json { render :show, status: :created, location: site_calendar_shift_path(@site.slug, @calendar, @shift) }
      else
        format.html { render :new }
        format.json { render json: @shift.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /shifts/1
  # PATCH/PUT /shifts/1.json
  def update
    respond_to do |format|
      if @shift.update(shift_params)
        format.html { redirect_to site_calendar_shift_path(@shift.calendar.site.slug, @shift.calendar, @shift), notice: 'Shift was successfully updated.' }
        format.json { render :show, status: :ok, location: site_calendar_shift_path(@shift.calendar.site.slug, @shift.calendar, @shift) }
      else
        format.html { render :edit }
        format.json { render json: @shift.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /shifts/1
  # DELETE /shifts/1.json
  def destroy
    @shift.destroy
    respond_to do |format|
      format.html { redirect_to shifts_url, notice: 'Shift was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_shift
      @site = Site.find_by(slug: params[:site_id])
      @calendar = @site.calendars.find(params[:calendar_id])
      @shift = @calendar.shifts.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def shift_params
      params.require(:shift).permit(
        :start_time, :end_time, 
        :efilers_needed_basic, :efilers_needed_advanced, 
        :calendar_id, 
        :day_of_week)
    end
end
