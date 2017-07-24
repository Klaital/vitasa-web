class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token
  
  def new
  end

  def create
    # Check for a JSON payload first
    email = nil
    password = nil
    json_request = false

    begin
      json_body = JSON.load(request.body.read)
      email = json_body['email'].downcase
      password = json_body['password']
      json_request = true
    rescue Exception => e
      email = params[:session][:email].downcase
      password = params[:session][:password]
    end

    user = User.find_by(email: email)
    if user && user.authenticate(password)
      log_in user
      if json_request
        render :json => { :message  => 'Login successful'}, :status => 200
        response.set_header('Content-Type', 'application/json')
      else
        redirect_to user
      end
    else
      if json_request
        render :json => { :errors => 'Invalid email/password combination'}, :status => 401
        response.set_header('Content-Type', 'application/json')
        return
      else
        flash.now[:danger] = 'Invalid email/password combination'
        render 'new'
      end
    end
  end

  def destroy
    log_out
    redirect_to root_url
  end
end
