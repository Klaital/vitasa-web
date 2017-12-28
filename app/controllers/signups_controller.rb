class SignupsController < ApplicationController
  before_action :set_signup, only: [:show, :edit, :update, :destroy]
  skip_before_action :verify_authenticity_token
  wrap_parameters :signup 

  # GET /signups
  # GET /signups.json
  def index
    
    site = params.has_key?('site') ? Site.find_by(slug: params['site']) : nil
    period_start = params.has_key?('start') ? Date.parse(params['start']) : Date.today
    period_end   = params.has_key?('end') ? Date.parse(params['end']) : Date.today + 365

    @signups = if site.nil?
                 Signup.all
               else
                 Signup.find_by_sql([
                   "SELECT signups.* FROM signups INNER JOIN shifts ON shifts.id = signups.shift_id INNER JOIN calendars ON calendars.id = shifts.calendar_id WHERE calendars.site_id = ? AND calendars.date BETWEEN ? AND ?",
                   site.id, period_start, period_end  
                 ])
               end
  end

  # GET /signups/1
  # GET /signups/1.json
  def show
  end

  # GET /signups/new
  def new
    @signup = Signup.new
  end

  # GET /signups/1/edit
  def edit
  end

  # POST /signups
  # POST /signups.json
  def create
    @shift = Shift.find(signup_params[:shift_id])
    @signup = @shift.signups.new(signup_params)
    
    respond_to do |format|
      if @signup.save
        # Invalidate the schedule API caches
        expire_schedule_cache

        format.html { redirect_to @signup, notice: 'Signup was successfully created.' }
        format.json { render :show, status: :created, location: @signup }
      else
        format.html { render :new }
        format.json { render json: @signup.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /signups/1
  # PATCH/PUT /signups/1.json
  def update
    respond_to do |format|
      if @signup.update(signup_params)
        # Invalidate the schedule API caches
        expire_schedule_cache
 
        format.html { redirect_to @signup, notice: 'Signup was successfully updated.' }
        format.json { render :show, status: :ok, location: @signup }
      else
        format.html { render :edit }
        format.json { render json: @signup.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /signups/1
  # DELETE /signups/1.json
  def destroy
    # Invalidate the schedule API caches
    expire_schedule_cache

    @signup.destroy
    respond_to do |format|
      format.html { redirect_to signups_url, notice: 'Signup was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_signup
      @signup = Signup.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def signup_params
      logger.debug(params)
      p = params.require(:signup).permit(:site, :user, :user_id, :shift_id, :hours, :approved)
      p[:user_id] = params[:user] unless params[:user].nil?
      p
    end
end
