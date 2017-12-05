class SuggestionsController < ApplicationController
  before_action :set_suggestion, only: [:show, :edit, :update, :destroy]
  skip_before_action :verify_authenticity_token
  
  # GET /suggestions
  # GET /suggestions.json
  def index
    if params.has_key?(:user_id)
      @suggestions = Suggestion.where(user_id: params[:user_id])
    else
      @suggestions = Suggestion.all
    end
   
    respond_to do |format|
      format.html
      format.json
      format.xls do
        headers['Content-Type'] ||= 'application/xls'
        headers['Content-Disposition'] = 'attachment; filename="suggestions.xls"'
      end
      format.csv do 
        headers['Content-Type'] ||= 'text/csv'
        headers['Content-Disposition'] = 'attachment; filename="suggestions.csv"'
      end
    end
  end

  # GET /suggestions/1
  # GET /suggestions/1.json
  def show
  end

  # GET /suggestions/new
  def new
    @suggestion = Suggestion.new
  end

  # GET /suggestions/1/edit
  def edit
  end

  # POST /suggestions
  # POST /suggestions.json
  def create
    logger.info request.env
    
    # Any logged-in user will be automatically attributed
    @suggestion = Suggestion.new(suggestion_params)
    @suggestion.user = current_user
    @suggestion.from_public = true unless logged_in?
    @suggestion.status = 'Open'

    respond_to do |format|
      if @suggestion.save
        format.html { redirect_to @suggestion, notice: 'Suggestion was successfully created.' }
        format.json { render :show, status: :created, location: @suggestion }
      else
        format.html { render :new }
        format.json { render json: @suggestion.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /suggestions/1
  # PATCH/PUT /suggestions/1.json
  def update
    unless logged_in?
      respond_to do |format|
        format.html { render :file => 'public/401', :status => :unauthorized, :layout => false }
        format.json { render :json => {:errors => 'Unauthorized'}, :status => :unauthorized }
      end
      return
    end

    respond_to do |format|
      if current_user == @suggestion.user || is_admin? || current_user.has_role?('Reviewer')
        if @suggestion.update(suggestion_params)
          format.html { redirect_to @suggestion, notice: 'Suggestion was successfully updated.' }
          format.json { render :show, status: :ok, location: @suggestion }
        else
          format.html { render :edit, :status => :unprocessable_entity }
          format.json { render json: @suggestion.errors, status: :unprocessable_entity }
        end
      else
        format.html { render :file => 'public/401', :status => :unauthorized, :layout => false }
        format.json { render :json => {:errors => 'Unauthorized'}, :status => :unauthorized }
      end
    end
  end

  # DELETE /suggestions/1
  # DELETE /suggestions/1.json
  def destroy
    # Admins and the creating user are permitted to destroy a suggestion. No one else
    unless logged_in? && (is_admin? || @suggestion.user == current_user)
      respond_to do |format|
        format.html { render :file => 'public/401', :status => :unauthorized, :layout => false }
        format.json { render :json => {:errors => 'Unauthorized'}, :status => :unauthorized }
      end
      return
    end

    @suggestion.destroy
    respond_to do |format|
      format.html { redirect_to new_suggestion_url, notice: 'Suggestion was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_suggestion
      @suggestion = Suggestion.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def suggestion_params
      # If it's a new record, then allow only subject, details and from_public. Owner and status will be left to default.
      # If it's an edit, and the user is the owner, allow those same three fields.
      # If it's an edit, and the user is an admin, allow all fields.
      # IF it's an edit, and the user is a Reviewer, allow only the status field
      allowed_fields = if @suggestion.nil? || @suggestion.new_record? || current_user == @suggestion.user
        [ :subject, :details, :from_public ]
      elsif is_admin?
        [ :subject, :details, :status, :from_public ]
      elsif current_user.has_role?('Reviewer')
        [ :status ]
      else
        []
      end
      
      params.require(:suggestion).permit(allowed_fields)
    end
end
