module SessionsHelper

  # Registers the given user as logged in.
  def log_in(user)
    session[:user_id] = user.id
  end

  # Returns the current logged-in user (if any).
  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  # Returns true if a user is logged in. False otherwise.
  def logged_in?
    !current_user.nil?
  end

  def is_admin?
    current_user.roles.each do |role|
      return true if role.name == 'Admin'
    end

    return false
  end


  # Logs out the current user
  def log_out
    session.delete(:user_id)
    @current_user = nil
  end
end
